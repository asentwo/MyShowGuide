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
    fileprivate init() {}
    
    let standardUserDefaults = Foundation.UserDefaults.standard
    let SAVED_SHOWS_KEY = "SAVED_SHOWS_KEY"
    
    func getSavedShows() -> [TvShowInfo] {
        
        let savedShows = standardUserDefaults.object(forKey: SAVED_SHOWS_KEY) as? Data
        
        if savedShows != nil {
            
            let savedShowsArrayTemp = NSKeyedUnarchiver.unarchiveObject(with: savedShows!) as? [TvShowInfo]
            
            if let savedShowsArray = savedShowsArrayTemp {
                // Everything is awesome - return the data!
                return savedShowsArray
            }
        }
        
        // We either found the key but there is NO data or there's NO key and NO data.
        // Either way, force creation!
        
        let emptySavedShowsArray = [TvShowInfo]()
        
        let emptySavedShows = NSKeyedArchiver.archivedData(withRootObject: emptySavedShowsArray)
        standardUserDefaults.set(emptySavedShows, forKey: SAVED_SHOWS_KEY)
        standardUserDefaults.synchronize()
        
        return emptySavedShowsArray
      //If nothing has ever been saved to the key, I go ahead and create  an empty array and just return that. That way people calling the function never have to worry about dealing with the possibility of a nil array. I also save this empty array so the key at least has something there.
    }
    
    
    func addFavorite(_ showToSave: TvShowInfo) {
    
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
            
            let savedShows = NSKeyedArchiver.archivedData(withRootObject: savedShowsArray)
            standardUserDefaults.set(savedShows, forKey: SAVED_SHOWS_KEY)
            standardUserDefaults.synchronize()
        }
    }
    
    
    func removeFavorite(_ showToRemove: TvShowInfo) {
        
        var savedShowsArray = getSavedShows()
        
        if savedShowsArray.count != 0 {
            
            // Try to find the show by id.
            let showsThatMatchIdArray = savedShowsArray.filter({$0.id == showToRemove.id})
            
            if showsThatMatchIdArray.isEmpty {
                print("removeFavorite couldn't find \(showToRemove.title) with id \(showToRemove.id)!")
            } else {
              
              //filtering out show to be removed from array
                savedShowsArray = savedShowsArray.filter({$0.id != showToRemove.id})
                
                let savedShows = NSKeyedArchiver.archivedData(withRootObject: savedShowsArray)
                standardUserDefaults.set(savedShows, forKey: SAVED_SHOWS_KEY)
                standardUserDefaults.synchronize()
                
                print("removeFavorite removed \(showToRemove.title) with id \(showToRemove.id).")
            }
            
        } else {
            print("removeFavorite couldn't find \(showToRemove.title) with id \(showToRemove.id)! Data saved at key was empty.")
        }
    }
    
    
    func isFavorite(_ id: NSNumber) -> Bool {
        
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
