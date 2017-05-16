//
//  TasksTableViewController.swift
//  TODOListApp
//
//  Created by Hayden Goldman on 5/15/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tasks :[Task]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateTasks()

    }
    
    private func populateTasks() {
        
        self.tasks = [Task]()
    
        let url = URL(string: "http://localhost:8080/tasks/get")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
            
            print(json)
            
            for item in json {
                
                let title = item["title"] as! String
                let taskId = item["taskId"] as! Int
                
                let task = Task()
                task.title = title
                task.taskId = taskId
                
                self.tasks.append(task)
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

            
        }.resume()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 44.0))
        headerView.backgroundColor = UIColor.lightText
        
        let textfield = UITextField(frame: headerView.frame)
        textfield.placeholder = "Enter task name"
        textfield.leftView = UIView(frame: CGRect(x: 10, y: 0, width: 10, height: 10))
        textfield.leftViewMode = .always
        textfield.delegate = self
        
        headerView.addSubview(textfield)
        
        return headerView
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let task = Task()
        task.title = textField.text!
        
        let url = URL(string: "http://localhost:8080/tasks/post")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: ["title":textField.text!], options: [])
        
        URLSession.shared.dataTask(with: request) { (data, _, _) in
            
            DispatchQueue.main.async {
                self.populateTasks()
            }
        }.resume()
        
//        self.tasks.append(task)
        
        textField.text = ""
        
        
        return textField.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        // Configure the cell...
        
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let task = self.tasks[indexPath.row]
            
            let url = URL(string: "http://localhost:8080/tasks/delete")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONSerialization.data(withJSONObject: ["taskId":task.taskId!], options: [])
            
            URLSession.shared.dataTask(with: request) { (data, _, _) in
                
                DispatchQueue.main.async {
                    self.populateTasks()
                }
                }.resume()

            
        }
    }





}
