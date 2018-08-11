//
//  Application+Testable.swift
//  ApiCoreTestTools
//
//  Created by Ondrej Rafaj on 27/02/2018.
//

import Foundation
@testable import DbCore
@testable import ApiCore
import Vapor
import Fluent
import VaporTestTools
import MailCore
import MailCoreTestTools


public struct Paths {
    
    public var rootUrl: URL {
        let config = DirectoryConfig.detect()
        let url = URL(fileURLWithPath: config.workDir)
        return url
    }
    
    public var resourcesUrl: URL {
        let url = rootUrl.appendingPathComponent("Resources")
        return url
    }
    
    public var publicUrl: URL {
        let url = rootUrl.appendingPathComponent("Public")
        return url
    }
    
}


extension TestableProperty where TestableType: Application {
    
    public static var paths: Paths {
        return Paths()
    }
    
    public static func newApiCoreTestApp(databaseConfig: DatabasesConfig? = nil, _ configClosure: AppConfigClosure? = nil, _ routerClosure: AppRouterClosure? = nil) -> Application {
        let app = new({ (config, env, services) in
            // Reset static configs
            DbCore.migrationConfig = MigrationConfig()
            ApiCoreBase.middlewareConfig = MiddlewareConfig()
            
            _ = ApiCoreBase.configuration
            ApiCoreBase._configuration?.database.host = "docker.for.mac.host.internal"
            ApiCoreBase._configuration?.database.user = "test"
            ApiCoreBase._configuration?.database.database = "boost-test"
            try! ApiCoreBase.configure(&config, &env, &services)
            
            // Set mailer mock
            MailerMock(services: &services)
            
            configClosure?(&config, &env, &services)
        }) { (router) in
            routerClosure?(router)
            try! ApiCoreBase.boot(router: router)
        }
        
        return app
    }
    
}
