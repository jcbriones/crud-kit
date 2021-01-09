import Vapor
import Fluent
import CRUDKit

final class Todo: Model, Content {
    static var schema = "todos"
    
    init() { }
    
    @ID(custom: "id")
    var id: Int?
    
    @Field(key: "title")
    var title: String
    
    @Children(for: \.$todo)
    var tags: [Tag]
    
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

extension Todo: CRUDModel {
    struct Public: Content {
        var id: Int?
        var title: String
        var isPublic: Bool
        var tagCount: Int
    }

    var `public`: Public {
        Public.init(id: id, title: title, isPublic: true, tagCount: 0)
    }
    
    func `public`(eventLoop: EventLoop, db: Database) -> EventLoopFuture<Public> {
        self.$tags.query(on: db).all().map {
            Public.init(id: self.id, title: self.title, isPublic: true, tagCount: $0.count)
        }
    }

    struct Create: Content {
        var title: String
    }

    convenience init(from data: Create) throws {
        self.init(title: data.title)
    }

    struct Replace: Content {
        var title: String
    }
    
    func replace(with data: Replace) throws -> Self {
        self.title = data.title
        return self
    }
}

extension Todo.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: .count(3...))
    }
}

extension Todo.Replace: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: .count(3...))
    }
}

extension Todo: Patchable {
    struct Patch: Content {
        var title: String?
    }
    
    func patch(with data: Patch) throws {
        self.title = data.title ?? self.title
    }
}

extension Todo.Patch: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: .count(3...))
    }
}

extension Todo {
    struct migration: Migration {
        var name = "TodoMigration"
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("todos")
                .field("id", .int, .identifier(auto: true))
                .field("title", .string, .required)
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("todos").delete()
        }
    }
}

extension Todo {
    static func seed(on database: Database) throws {
        try Todo(title: "Wash clothes").save(on: database).wait()
        try Todo(title: "Read book").save(on: database).wait()
        try Todo(title: "Prepare dinner").save(on: database).wait()
    }
}
