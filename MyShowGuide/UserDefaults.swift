//
//  UserDefaults.swift
//  MyShowGuide
//
//  Created by Kevin Harris on 4/20/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation

class UserDefaults {
    
    static let sharedInstance = UserDefaults()
    
    // This prevents others from using the default '()' initializer for this class.
    private init() {}
    
    let standardUserDefaults = NSUserDefaults.standardUserDefaults()
    let SAVED_SHOWS_KEY = "SAVED_SHOWS_KEY"
    
    func getSavedShows() -> [TvShowInfo] {
        
        let savedShows = standardUserDefaults.objectForKey(SAVED_SHOWS_KEY) as? NSData
        
        if savedShows != nil {
            
            let savedShowsArrayTemp = NSKeyedUnarchiver.unarchiveObjectWithData(savedShows!) as? [TvShowInfo]
            
            if let savedShowsArray = savedShowsArrayTemp {
                // Everything is awesome - return the data!
                return savedShowsArray
            }
        }
        
        // We either found the key but there is NO data or there's NO key and NO data.
        // Either way, force creation!
        
        let emptySavedShowsArray = [TvShowInfo]()
        
        let emptySavedShows = NSKeyedArchiver.archivedDataWithRootObject(emptySavedShowsArray)
        standardUserDefaults.setObject(emptySavedShows, forKey: SAVED_SHOWS_KEY)
        standardUserDefaults.synchronize()
        
        return emptySavedShowsArray
    }
    
    
    func addFavorite(showToSave: TvShowInfo) {
    
        var savedShowsArray = getSavedShows()
        var addShow = false
        
        if savedShowsArray.count != 0 {
            
            // Try to find the show by id.
            let showsThatMatchIdArray = savedShowsArray.filter({$0.id == showToSave.id})
            
            if showsThatMatchIdArray.isEmpty {
                // We couldn't find a duplicate id for this show, so add it!
                addShow = true
            } else {
                print("addFavorite attempted to save a duplicate of \(showToSave.title) with id \(showToSave.id)!")
            }
            
        } else {
            // We have an array but it is empty - add the new saved show!
            addShow = true
        }
        
        if addShow {
            
            savedShowsArray.append(showToSave)
            
            print("addFavorite added \(showToSave.title) with id \(showToSave.id).")
            
            let savedShows = NSKeyedArchiver.archivedDataWithRootObject(savedShowsArray)
            standardUserDefaults.setObject(savedShows, forKey: SAVED_SHOWS_KEY)
            standardUserDefaults.synchronize()
        }
    }
    
    
    func removeFavorite(showToRemove: TvShowInfo) {
        
        var savedShowsArray = getSavedShows()
        
        if savedShowsArray.count != 0 {
            
            // Try to find the show by id.
            let showsThatMatchIdArray = savedShowsArray.filter({$0.id == showToRemove.id})
            
            if showsThatMatchIdArray.isEmpty {
                print("removeFavorite couldn't find \(showToRemove.title) with id \(showToRemove.id)!")
            } else {
                
                savedShowsArray = savedShowsArray.filter({$0.id != showToRemove.id})
                
                let savedShows = NSKeyedArchiver.archivedDataWithRootObject(savedShowsArray)
                standardUserDefaults.setObject(savedShows, forKey: SAVED_SHOWS_KEY)
                standardUserDefaults.synchronize()
                
                print("removeFavorite removed \(showToRemove.title) with id \(showToRemove.id).")
            }
            
        } else {
            print("removeFavorite couldn't find \(showToRemove.title) with id \(showToRemove.id)! Data saved at key was empty.")
        }
    }
    
    
    func isFavorite(id: NSNumber) -> Bool {
        
        let savedShowsArray = getSavedShows()

        if savedShowsArray.count != 0 {
            
            // Try to find the show by id.
            let showsThatMatchIdArray = savedShowsArray.filter({$0.id == id})
            
            if showsThatMatchIdArray.isEmpty {
                return false // No match on id, so it couldn't be a favorite.
            } else {
                return true // We found a match!
            }
            
        } else {
            return false // Saved shows was empty, so it couldn't be a favorite.
        }
    }
}
