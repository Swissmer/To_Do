//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by Даниил Семёнов on 24.05.2024.
//

import UIKit

class TaskListController: UITableViewController {
    
    // хранилище задач
    var taskStorage: TaskStorageProtocol = TaskStorage()
    // коллекция задач
    var tasks: [TaskPriority: [TaskProtocol]] = [:]
    // секции
    var sectionsTypesPosition: [TaskPriority] = [.high, .normal]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // загрузка задач
        loadTasks()
    }
    
    private func loadTasks() {
        // подготовка коллекции с задачам
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        // загрузска задач из хранилища
        taskStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskType = sectionsTypesPosition[section]
        guard let currentTaskType = tasks[taskType] else {
            return 0
        }
        return currentTaskType.count
    }
    
    private func getConfiguredTaskCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        // получение символа
        let symbolCell = cell.viewWithTag(1) as? UILabel
        // получение ячейки
        let titleCell = cell.viewWithTag(2) as? UILabel
        
        // изменяем символ ячейки
        symbolCell?.text = getSymbol(with: currentTask.status)
        // изменяем текст
        titleCell?.text = currentTask.title
        
        if currentTask.status == .planned {
            symbolCell?.textColor = .black
            titleCell?.textColor = .black
        } else {
            symbolCell?.textColor = .gray
            titleCell?.textColor = .gray
        }
        
        return cell
    }
    
    private func getSymbol(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .comleted {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        
        return resultSymbol
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return getConfiguredTaskCell(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var taskType = sectionsTypesPosition[section]
        var title: String?
        
        if taskType == .high {
            title = "Важные"
        } else if taskType == .normal {
            title = "Текущие"
        }
        
        return title
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
