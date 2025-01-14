//
//  ViewController.swift
//  aghani
//
//  Created by Abdulrahman Negmeldin on 2025-01-14.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet var table: UITableView!
    
    var songs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSongs()
        table.delegate = self
        table.dataSource = self
    }
    
    func configureSongs(){
        songs.append(Song(name: "Ya Abyad Ya Eswed",
                          albumName: "The Ugly Duckling",
                          artistName: "Cairokee",
                          imageName: "cover1",
                          trackName: "song2"))
        
        songs.append(Song(name: "Hob Hob",
                          albumName: "The Ugly Duckling",
                          artistName: "Cairokee",
                          imageName: "cover1",
                          trackName: "song1"))
        
        songs.append(Song(name: "Kan Lak Maaya",
                          albumName: "The Ugly Duckling",
                          artistName: "Cairokee",
                          imageName: "cover1",
                          trackName: "song3"))
        
        songs.append(Song(name: "Lelly",
                          albumName: "Lelly",
                          artistName: "Mohamed Mounir",
                          imageName: "cover2",
                          trackName: "song4"))
        
        songs.append(Song(name: "Taam El Biyout",
                          albumName: "Taam El Biyout",
                          artistName: "Mohamed Mounir",
                          imageName: "cover3",
                          trackName: "song5"))
    }
    
        //Table
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return songs.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let song = songs[indexPath.row]
            
            //comfigure cell
            cell.textLabel?.text = song.name
            cell.detailTextLabel?.text = song.albumName
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage(named: song.imageName)
            cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 18)
            cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 17)

            
            return cell
        }
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
            tableView.deselectRow(at: indexPath, animated: true)
            
            //present the player
            let position = indexPath.row
            
            //songs
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "player") as? PlayerViewController else {
                return
            }
            vc.songs = songs
            vc.position = position
            
            present(vc, animated: true)
        }
        
        
    


}

struct Song {
    let name: String
    let albumName: String
    let artistName: String
    let imageName: String
    let trackName: String
}

