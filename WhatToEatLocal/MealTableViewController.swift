//
//  MealTableViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 6.02.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {

    var meals = [Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMeals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell..
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = #imageLiteral(resourceName: "Meal1")
        cell.durationLabel.text = String(meal.durationInMinutes)
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private func loadMeals(){
        guard let url = URL(string: "http://ec2-34-209-47-4.us-west-2.compute.amazonaws.com:8080/homemademeals") else {
            return
        }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let data = data {
                print(data)
                do {
                    self.meals = try JSONDecoder().decode([Meal].self, from: data)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    return
                } catch let jsonErr {
                    os_log("Error serializing json:", log: OSLog.default, type: .debug)
                    fatalError("Error serializing json:" + jsonErr.localizedDescription)
                }
            }
            }.resume()
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        loadMeals()
    }

}
