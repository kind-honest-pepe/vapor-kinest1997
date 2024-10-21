//
//  File.swift
//  vapor-kinest1997
//
//  Created by kang on 10/21/24.
//

import Foundation
import Fluent
import Vapor

struct PepeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let pepes = routes.grouped("pepe")
        pepes.get("random", use: randomPepe)
    }

    @Sendable
    func index(req: Request) async throws -> [TodoDTO] {
        try await Todo.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> TodoDTO {
        let todo = try req.content.decode(TodoDTO.self).toModel()

        try await todo.save(on: req.db)
        return todo.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await todo.delete(on: req.db)
        return .noContent
    }
    
    @Sendable
    func modify(req: Request) async throws -> HTTPStatus {
        return .ok
    }
    
    @Sendable
    func randomPepe(req: Request) async throws -> Response {
       // 이미지들이 저장된 디렉토리 경로 설정
        
        let imageDirectory = req.application.directory.publicDirectory + "Pepe/"

        // 디렉토리 내 파일 목록 불러오기
        let fileManager = FileManager.default
        do {
           // 해당 디렉토리 내 파일 목록 가져오기
           let allFiles = try fileManager.contentsOfDirectory(atPath: imageDirectory)
           
//           // 이미지 파일만 필터링
//           let imageFiles = allFiles.filter { file in
//               let fileExtension = file.split(separator: ".").last?.lowercased()
//               return ["png", "jpg", "jpeg", "gif", "avif"].contains(fileExtension ?? "")
//           }
           
           guard !allFiles.isEmpty else {
               throw Abort(.notFound, reason: "No images found in directory.")
           }
           
           // 랜덤하게 하나의 이미지 선택
           let randomImage = allFiles.randomElement()!
           let imagePath = imageDirectory + randomImage
           
           // 해당 파일을 클라이언트에 반환
           return req.fileio.streamFile(at: imagePath)
        } catch {
           throw Abort(.internalServerError, reason: "Failed to access images in directory.")
        }
    }
}
