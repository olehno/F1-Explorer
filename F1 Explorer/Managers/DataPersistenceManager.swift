//
//  DataPersistenceManager.swift
//  F1 Explorer
//
//  Created by Артур Олехно on 09/11/2023.
//

import Foundation
import UIKit
import CoreData

class DataPersistenceManager {
    
    enum DatabaseError: Error {
        case failedToSave
        case failedToFetchData
        case failedToDeleteData
        case itemNotFound
        case failedToUpdate
    }
    
    static let shared = DataPersistenceManager()
    
    // MARK: - Drivers CoreData
    
    func saveDriverWith(model: DriverDetailViewModel, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let item = DriverItem(context: context)
        
        item.id = Int64(model.id)
        item.name = model.name
        item.image = model.image
        item.countryName = model.country
        item.birthdate = model.birthDate
        item.number = Int64(model.number)
        item.world_championships = Int64(model.worldChampionships)
        item.podiums = Int64(model.podiums)
        item.logo = model.driverTeamLogo
        item.teamName = model.driverTeamName
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToSave))
        }
    }
    
    func fetchingDriversFromDatabase(completion: @escaping (Result<[DriverItem], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<DriverItem>
        request = DriverItem.fetchRequest()
        
        do {
            let drivers = try context.fetch(request)
            completion(.success(drivers))
        } catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func deleteDriverWith(model: DriverItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(model)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDeleteData))
        }
    }
    
    // MARK: - Reaction CoreData
    
    func saveReactionWith(newRactionTime: Double, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        let item = ReactionItem(context: context)
        item.reactionTime = newRactionTime
        item.id = 1
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToSave))
        }
    }
    
    func fetchingReactionFromDatabase(completion: @escaping (Result<ReactionItem?, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let request: NSFetchRequest<ReactionItem>
        request = ReactionItem.fetchRequest()

        do {
            if let reaction = try context.fetch(request).first {
                completion(.success(reaction))
            } else {
                // No reaction found
                completion(.success(nil))
            }
        } catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func updateReaction(oldReactionTime: Double, newRactionTime: Double, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let fetchRequest: NSFetchRequest<ReactionItem> = ReactionItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: 1))
            
            do {
                let data = try context.fetch(fetchRequest)
                if data.count == 1 {
                    let objectUpdate = data[0] as NSManagedObject
                    objectUpdate.setValue(newRactionTime, forKey: "reactionTime")
                    appDelegate.saveContext()
                    completion(.success(()))
                }
            } catch {
                completion(.failure(DatabaseError.failedToUpdate))
            }
        }
    }
}
