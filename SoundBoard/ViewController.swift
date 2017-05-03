//
//  ViewController.swift
//  SoundBoard
//
//  Created by Enrique V. Kortright on 5/3/17.
//  Copyright © 2017 Enrique V. Kortright. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var sounds : [Sound] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        do {
            sounds = try context.fetch(Sound.fetchRequest()) as! [Sound]
            tableView.reloadData()
            print(sounds)
        } catch {
            print("Error loading guitar CoreData")
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let sound = sounds[indexPath.row]
        cell.textLabel?.text = sound.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt: \(indexPath.row)")
        let sound = sounds[indexPath.row]
        performSegue(withIdentifier: "soundViewSegue", sender: sound)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue with sender: \(sender!)")
        let nextVC = segue.destination as! SoundViewController
        nextVC.sound = sender as? Sound
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("editingStyle: .delete")
            let sound = sounds[indexPath.row]
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            context.delete(sound)
            delegate.saveContext()
            do {
                sounds = try context.fetch(Sound.fetchRequest()) as! [Sound]
                tableView.reloadData()
            } catch {
                print("Error deleting sound")
            }
        }
    }
}

