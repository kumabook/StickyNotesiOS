//
//  StickyRepository.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import Foundation
import RealmSwift
import APIKit
import ReactiveCocoa

class StickyRepository {
    enum State {
        case Normal
        case Updating
        case Fetching
    }
    var state: MutableProperty<State> = MutableProperty(.Normal)
    var realm: Realm = try! Realm()
    static var sharedInstance: StickyRepository = StickyRepository()
    var items: Results<StickyEntity> {
        return realm.objects(StickyEntity.self).filter("state != 1").sorted("updatedAt", ascending: false)
    }
    var tags: Results<TagEntity> {
        return realm.objects(TagEntity.self).sorted("name")
    }
    var pages: Results<PageEntity> {
        return realm.objects(PageEntity.self).filter("_stickies.@count >= 1").sorted("title")
    }

    func updateStickies(callback: (Bool) -> ()) {
        if state.value == .Updating { return }
        state.value = .Updating
        let request = UpdateStickiesRequest(stickies: self.realm.objects(TrashedStickyEntity.self).map { $0 })
        Session.sendRequest(request) { result in
            switch result {
            case .Success:
                self.state.value = .Normal
                callback(true)
            case .Failure(let error):
                print("failure: \(error)")
                self.state.value = .Normal
                callback(false)
            }
        }
    }

    func fetchStickies(callback: (Bool) -> ()) {
        if state.value == .Fetching { return }
        state.value = .Fetching
        let request = StickiesRequest(newerThan: APIClient.sharedInstance.lastSyncedAt)
        Session.sendRequest(request) { result in
            switch result {
            case .Success(let stickies):
                stickies.value.forEach {
                    if $0.state == .Deleted {
                        if let s = StickyEntity.findBy(uuid: $0.uuid) {
                            StickyRepository.sharedInstance.removeSticky(s)
                        }
                        return
                    }
                    do {
                        let entity = StickyEntity()
                        entity.id = $0.id
                        entity.uuid = $0.uuid
                        entity.left = $0.left
                        entity.top = $0.top
                        entity.width = $0.width
                        entity.height = $0.height
                        entity.content = $0.content
                        entity.color = $0.color
                        entity.state = $0.state.rawValue
                        entity.createdAt = $0.createdAt
                        entity.updatedAt = $0.updatedAt
                        entity.userId = $0.userId
                        entity.page = PageEntity(value: ["url": $0.page.url, "title": $0.page.title])
                        entity.tags.appendContentsOf($0.tags.map { TagEntity(value: ["name": $0]) })
                        try self.realm.write {
                            self.realm.add(entity, update: true)
                        }
                    } catch  {
                        print("error")
                    }
                }
                self.state.value = .Normal
                APIClient.sharedInstance.lastSyncedAt = NSDate()
                callback(true)
                print("stickies \(stickies)")
            case .Failure(let error):
                print("error: \(error)")
                self.state.value = .Normal
                callback(false)
            }
        }
    }

    func saveSticky(sticky: StickyEntity, newSticky: StickyEntity) -> Bool {
        do {
            try self.realm.write {
                sticky.content   = newSticky.content
                sticky.updatedAt = newSticky.updatedAt
                sticky.color     = newSticky.color
                sticky.left      = newSticky.left
                sticky.top       = newSticky.top
                sticky.width     = newSticky.width
                sticky.height    = newSticky.height
                sticky.tags.removeAll()

                sticky.tags.appendContentsOf(newSticky.tags)
            }
        } catch {
            return false
        }
        return true
    }

    func removeSticky(sticky:  StickyEntity) -> Bool {
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
    dynamic var createdAt: NSDate = NSDate()
    dynamic var updatedAt: NSDate = NSDate()
    dynamic var userId:    Int = 0
    dynamic var page:      PageEntity?
    let tags = List<TagEntity>()
    override static func primaryKey() -> String? {
        return "uuid"
    }
    static func findBy(uuid uuid: String) -> StickyEntity? {
        let realm: Realm = try! Realm()
        if let sticky = realm.objectForPrimaryKey(StickyEntity.self, key: uuid) {
            return sticky
        }
        return nil
    }
    func toParameter() -> [String:AnyObject] {
        return  [
                    "id": id,
                  "uuid": uuid,
                  "left": left,
                   "top": top,
                 "width": width,
                "height": height,
               "content": content,
                 "color": color,
                 "state": state,
            "created_at": DateFormatter.sharedInstance.stringFromDate(createdAt),
            "updated_at": DateFormatter.sharedInstance.stringFromDate(updatedAt),
               "user_id": userId,
                   "url":  page!.url,
                 "title": page!.title,
                  "tags": tags.map { $0.name }
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
        let data = try NSJSONSerialization.dataWithJSONObject(toParameter(), options: NSJSONWritingOptions.PrettyPrinted)
        return String(data: data, encoding: NSUTF8StringEncoding)!
    }
}

class TrashedStickyEntity: StickyEntity {
    static func build(sticky: StickyEntity) -> TrashedStickyEntity {
        let trashed = TrashedStickyEntity()
        trashed.id        = sticky.id
        trashed.uuid      = sticky.uuid
        trashed.left      = sticky.left
        trashed.top       = sticky.top
        trashed.width     = sticky.width
        trashed.height    = sticky.height
        trashed.content   = sticky.content
        trashed.color     = sticky.color
        trashed.state     = Sticky.State.Deleted.rawValue
        trashed.createdAt = sticky.createdAt
        trashed.updatedAt = sticky.updatedAt
        trashed.userId    = sticky.userId
        trashed.page      = sticky.page
        return trashed
    }
}

class PageEntity: Object {
    dynamic var url:   String = ""
    dynamic var title: String = ""
    let _stickies = LinkingObjects(fromType: StickyEntity.self, property: "page")
    var stickies: Results<StickyEntity> { return _stickies.filter("state != 1") }
    override static func primaryKey() -> String? {
        return "url"
    }
}

class TagEntity: Object {
    dynamic var name: String = ""
    let stickies = LinkingObjects(fromType: StickyEntity.self, property: "tags")
    override static func primaryKey() -> String? {
        return "name"
    }
    static func findBy(name name: String) -> TagEntity? {
        let realm: Realm = try! Realm()
        if let tag = realm.objectForPrimaryKey(TagEntity.self, key: name) {
            return tag
        }
        return nil
    }
    static func findOrCreateBy(name name: String) -> TagEntity {
        if let tag = findBy(name: name) {
            return tag
        }
        let tag = TagEntity()
        tag.name = name
        return tag
    }
}