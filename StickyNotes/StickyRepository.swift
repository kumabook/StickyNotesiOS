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

class StickyRepository {
    var realm: Realm = try! Realm()
    static var sharedInstance: StickyRepository = StickyRepository()
    var items: Results<StickyEntity> {
        return realm.objects(StickyEntity.self)
    }
    var tags: Results<TagEntity> {
        return realm.objects(TagEntity.self).sorted("name")
    }
    func fetchStickies() {
        let request = StickiesRequest(newerThan: NSDate(timeIntervalSince1970: 0))
        Session.sendRequest(request) { result in
            switch result {
            case .Success(let stickies):
                stickies.value.forEach {
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
                print("stickies \(stickies)")
            case .Failure(let error):
                print("error: \(error)")
            }
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
}

class PageEntity: Object {
    dynamic var url:   String = ""
    dynamic var title: String = ""
    override static func primaryKey() -> String? {
        return "url"
    }
}

class TagEntity: Object {
    dynamic var name: String = ""
    override static func primaryKey() -> String? {
        return "name"
    }
}