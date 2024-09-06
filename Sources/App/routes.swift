import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, vapor!"
    }
    
    app.get("hello") { req async -> String in
        "Hello, vapor!"
    }

    try app.register(collection: TodoController())
}
