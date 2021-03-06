//
//  StickyRepository.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import APIKit
import ReactiveSwift
import Breit

class StickyRepository {
    enum State {
        case normal
        case updating
        case fetching
    }
    var state: MutableProperty<State> = MutableProperty(.normal)
    var realm: Realm = try! Realm()
    static var shared: StickyRepository = StickyRepository()
    var items: Results<StickyEntity> {
        return realm.objects(StickyEntity.self).filter("state != 1").sorted(byKeyPath: "updatedAt", ascending: false)
    }
    var tags: Results<TagEntity> {
        return realm.objects(TagEntity.self).sorted(byKeyPath: "name")
    }
    var pages: Results<PageEntity> {
        return realm.objects(PageEntity.self).filter("_stickies.@count >= 1").sorted(byKeyPath: "title")
    }

    func newStickies(_ sticky: StickyEntity, callback: @escaping (Bool) -> ()) {
        let request = UpdateStickiesRequest(stickies: [sticky])
        Session.send(request) { result in
            switch result {
            case .success:
                self.state.value = .normal
                callback(true)
            case .failure(let error):
                print("failure: \(error)")
                self.state.value = .normal
                callback(false)
            }
        }
    }

    func updateStickies() -> SignalProducer<Void, NSError> {
        if state.value == .updating { return SignalProducer<Void, NSError>.empty }
        state.value = .updating
        return SignalProducer<Void, NSError> { (observer, disposable) in
            let lastSyncedAt = APIClient.shared.lastSyncedAt ?? Date(timeIntervalSince1970: 0)
            let predicate = NSPredicate(format: "updatedAt > %@", lastSyncedAt as NSDate)
            var stickies: [StickyEntity] = []
            stickies.append(contentsOf: self.realm.objects(StickyEntity.self).filter(predicate).map { $0 })
            stickies.append(contentsOf: self.realm.objects(TrashedStickyEntity.self).map { $0 })
            let request = UpdateStickiesRequest(stickies: stickies)
            Session.send(request) { result in
                switch result {
                case .success:
                    self.state.value = .normal
                    try? self.realm.write {
                        self.realm.delete(self.realm.objects(TrashedStickyEntity.self))
                    }
                    observer.send(value: ())
                    observer.sendCompleted()
                case .failure(let error):
                    print("failure: \(error)")
                    self.state.value = .normal
                    observer.send(error: error as NSError)
                }
            }
        }
    }

    func fetchStickies() -> SignalProducer<Void, NSError> {
        if state.value == .fetching { return SignalProducer<Void, NSError>.empty }
        state.value = .fetching
        return SignalProducer<Void, NSError> { (observer, disposable) in
            let lastSyncedAt = APIClient.shared.lastSyncedAt ?? Date(timeIntervalSince1970: 0)
            let request = StickiesRequest(newerThan: lastSyncedAt)
            Session.send(request) { result in
                switch result {
                case .success(let stickies):
                    stickies.value.forEach {
                        if $0.state == .deleted {
                            if let s = StickyEntity.findBy(uuid: $0.uuid) {
                                let _ = StickyRepository.shared.removeSticky(s)
                            }
                            return
                        }
                        do {
                            if let entity = StickyEntity.findBy(uuid: $0.uuid) {
                                try entity.update(sticky: $0)
                            } else {
                                let entity = StickyEntity(sticky: $0)
                                try self.realm.write {
                                    self.realm.add(entity, update: true)
                                }
                            }
                        } catch  {
                            print("error")
                        }
                    }
                    self.state.value = .normal
                    observer.send(value: ())
                    observer.sendCompleted()
                case .failure(let error):
                    print("error: \(error)")
                    self.state.value = .normal
                    observer.send(error: error as NSError)
                }
            }
        }
    }

    func updatePage(_ page: PageEntity, newPage: Page) -> Bool {
        do {
            try self.realm.write {
                page.title = newPage.title
                page.visualUrl = newPage.visualUrl
            }
        } catch {
            return false
        }
        return true
    }

    func fetchPages() -> SignalProducer<Void, NSError> {
        if state.value == .fetching { return SignalProducer<Void, NSError>.empty }
        state.value = .fetching
        return SignalProducer<Void, NSError> { (observer, disposable) in
            let lastSyncedAt = APIClient.shared.lastSyncedAt ?? Date(timeIntervalSince1970: 0)
            let request = PagesRequest(newerThan: lastSyncedAt)
            Session.send(request) { result in
                switch result {
                case .success(let pages):
                    pages.value.forEach {
                        if let pageEntity = PageEntity.findBy(url: $0.url) {
                            let _ = StickyRepository.shared.updatePage(pageEntity, newPage: $0)
                        }
                    }
                    self.state.value = .normal
                    observer.send(value: ())
                    observer.sendCompleted()
                case .failure(let error):
                    print("error: \(error)")
                    self.state.value = .normal
                    observer.send(error: error as NSError)
                }
            }
        }
    }

    func createSticky(_ sticky: StickyEntity) -> Bool {
        do {
            try self.realm.write {
                realm.add(sticky)
            }
        } catch {
            return false
        }
        return true
    }

    func saveSticky(_ sticky: StickyEntity, newSticky: StickyEntity) -> Bool {
        do {
            try self.realm.write {
                sticky.content   = newSticky.content
                sticky.updatedAt = Date()
                sticky.color     = newSticky.color
                sticky.left      = newSticky.left
                sticky.top       = newSticky.top
                sticky.width     = newSticky.width
                sticky.height    = newSticky.height
                sticky.tags.removeAll()

                sticky.tags.append(contentsOf: newSticky.tags)
            }
        } catch {
            return false
        }
        return true
    }

    func removeSticky(_ sticky:  StickyEntity) -> Bool {
        do {
            try self.realm.write {
                self.realm.add(TrashedStickyEntity.build(sticky))
                self.realm.delete(sticky)
            }
        } catch {
            return false
        }
        return true
    }

    func clear() {
        do {
            try self.realm.write {
                self.realm.deleteAll()
            }
        } catch {
            print("Failed to delete")
        }
    }
}

class StickyEntity: Object {
    dynamic var id:        Int = 0
    dynamic var uuid:      String = ""
    dynamic var left:      Int = 0
    dynamic var top:       Int = 0
    dynamic var width:     Int = 0
    dynamic var height:    Int = 0
    dynamic var content:   String = ""
    dynamic var color:     String = ""
    dynamic var state:     Int = 0
    dynamic var createdAt: Date = Date()
    dynamic var updatedAt: Date = Date()
    dynamic var userId:    Int = 0
    dynamic var page:      PageEntity?
    var tags = List<TagEntity>()
    override static func primaryKey() -> String? {
        return "uuid"
    }

    convenience init(sticky: Sticky) {
        self.init()
        id        = sticky.id
        uuid      = sticky.uuid
        left      = sticky.left
        top       = sticky.top
        width     = sticky.width
        height    = sticky.height
        content   = sticky.content
        color     = sticky.color
        state     = sticky.state.rawValue
        createdAt = sticky.createdAt as Date
        updatedAt = sticky.updatedAt as Date
        userId    = sticky.userId
        page      = PageEntity.findOrCreateBy(url: sticky.page.url)
        try? realm?.write {
            page?.title     = sticky.page.title
            page?.visualUrl = sticky.page.visualUrl
        }
        tags.append(contentsOf: sticky.tags.map { TagEntity.findOrCreateBy(name: $0) })
    }

    func update(sticky: Sticky) throws {
        try self.realm?.write {
            id        = sticky.id
            left      = sticky.left
            top       = sticky.top
            width     = sticky.width
            height    = sticky.height
            content   = sticky.content
            color     = sticky.color
            state     = sticky.state.rawValue
            createdAt = sticky.createdAt as Date
            updatedAt = sticky.updatedAt as Date
            userId    = sticky.userId
            page      = PageEntity.findOrCreateBy(url: sticky.page.url)
            page?.title     = sticky.page.title
            page?.visualUrl = sticky.page.visualUrl
            tags.removeAll()
            tags.append(contentsOf: sticky.tags.map { TagEntity.findOrCreateBy(name: $0) })
        }
    }

    static func findBy(uuid: String) -> StickyEntity? {
        let realm: Realm = try! Realm()
        if let sticky = realm.object(ofType: StickyEntity.self, forPrimaryKey: uuid) {
            return sticky
        }
        return nil
    }
    static func search(by query: String) -> Results<StickyEntity> {
        let realm: Realm = try! Realm()
        return realm.objects(StickyEntity.self).filter(
            "content        CONTAINS[c] %@ OR " +
            "page.title     CONTAINS[c] %@ OR " +
            "page.url       CONTAINS[c] %@ OR " +
            "ANY tags.name  CONTAINS[c] %@",
            query,
            query,
            query,
            query)
    }
    static func empty() -> Results<StickyEntity> {
        let realm: Realm = try! Realm()
        return realm.objects(StickyEntity.self).filter("id == 0")
    }
    func toParameter() -> [String:Any] {
        return  [
                    "id": id as Any,
                  "uuid": uuid as Any,
                  "left": left as Any,
                   "top": top as Any,
                 "width": width as Any,
                "height": height as Any,
               "content": content as Any,
                 "color": color,
                 "state": state,
            "created_at": DateFormatter.shared.string(from: createdAt),
            "updated_at": DateFormatter.shared.string(from: updatedAt),
               "user_id": userId,
                   "url": page!.url,
                 "title": page!.title,
                  "tags": tags.map { $0.name } as [String],
                  "page": page != nil ? ["url": page!.url, "title": page!.title] : [:]
        ]
    }
    func clone() -> StickyEntity {
        let e = StickyEntity()
        e.id = id
        e.uuid = uuid
        e.left = left
        e.top = top
        e.width = width
        e.height = height
        e.content = content
        e.color = color
        e.state = state
        e.createdAt = createdAt
        e.updatedAt = updatedAt
        e.userId = userId
        return e
    }
    var backgroundColor: UIColor? {
        return Color.get(color)?.backgroundColor
    }
    var fontColor: UIColor? {
        return Color.get(color)?.fontColor
    }
    func toJSONString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: toParameter(), options: JSONSerialization.WritingOptions.prettyPrinted)
        return String(data: data, encoding: String.Encoding.utf8)!
    }
}

class TrashedStickyEntity: StickyEntity {
    static func build(_ sticky: StickyEntity) -> TrashedStickyEntity {
        let trashed = TrashedStickyEntity()
        trashed.id        = sticky.id
        trashed.uuid      = sticky.uuid
        trashed.left      = sticky.left
        trashed.top       = sticky.top
        trashed.width     = sticky.width
        trashed.height    = sticky.height
        trashed.content   = sticky.content
        trashed.color     = sticky.color
        trashed.state     = Sticky.State.deleted.rawValue
        trashed.createdAt = sticky.createdAt
        trashed.updatedAt = sticky.updatedAt
        trashed.userId    = sticky.userId
        trashed.page      = sticky.page
        return trashed
    }
}

class PageEntity: Object {
    dynamic var url:       String  = ""
    dynamic var title:     String  = ""
    dynamic var visualUrl: String? = nil
    let _stickies = LinkingObjects(fromType: StickyEntity.self, property: "page")
    var stickies: Results<StickyEntity> { return _stickies.filter("state != 1") }
    override static func primaryKey() -> String? {
        return "url"
    }
    static func findBy(url: String) -> PageEntity? {
        let realm: Realm = try! Realm()
        if let page = realm.object(ofType: PageEntity.self, forPrimaryKey: url) {
            return page
        }
        return nil
    }
    static func findOrCreateBy(url: String, title: String = "", visualUrl: String? = nil) -> PageEntity {
        if let page = findBy(url: url) {
            return page
        }
        let page       = PageEntity()
        page.url       = url
        page.title     = title
        page.visualUrl = visualUrl
        return page
    }
}

class TagEntity: Object {
    dynamic var name: String = ""
    let stickies = LinkingObjects(fromType: StickyEntity.self, property: "tags")
    override static func primaryKey() -> String? {
        return "name"
    }
    static func findBy(name: String) -> TagEntity? {
        let realm: Realm = try! Realm()
        if let tag = realm.object(ofType: TagEntity.self, forPrimaryKey: name) {
            return tag
        }
        return nil
    }
    static func findOrCreateBy(name: String) -> TagEntity {
        if let tag = findBy(name: name) {
            return tag
        }
        let tag = TagEntity()
        tag.name = name
        return tag
    }
}
