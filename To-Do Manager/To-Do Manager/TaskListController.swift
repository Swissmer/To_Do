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
    var tasks: [TaskPriority: [TaskProtocol]] = [:] {
        didSet {
            for (taskGroupPrioruty, taskGroup) in tasks {
                tasks[taskGroupPrioruty] = taskGroup.sorted { task1, task2 in
                    let taskPosition1 = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let taskPosition2 = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    
                    return taskPosition1 < taskPosition2
                }
            }
        }
    }
    // секции
    var sectionsTypesPosition: [TaskPriority] = [.high, .normal]
    // порядок отображения задач
    var tasksStatusPosition: [TaskStatus] = [.planned, .comleted]
    
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
    
    private func getConfiguredTaskCell_contraint(for indexPath: IndexPath) -> UITableViewCell {
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
    
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        
        let taskType = sectionsTypesPosition[indexPath.section]
        
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        cell.title.text = currentTask.title
        cell.symbol.text = getSymbol(with: currentTask.status)
        
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .gray
            cell.symbol.textColor = .gray
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

        // на основе ограничений
        // return getConfiguredTaskCell_contraint(for: indexPath)
        // на основе стека
        return getConfiguredTaskCell_stack(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let taskType = sectionsTypesPosition[section]
        var title: String?
        
        if taskType == .high {
            title = "Важные"
        } else if taskType == .normal {
            title = "Текущие"
        }
        
        return title
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // проверяем существование задачи
        let taskType = sectionsTypesPosition[indexPath.section]
        guard var _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        
        if tasks[taskType]?[indexPath.row].status == .planned {
            tasks[taskType]?[indexPath.row].status = .comleted
        } else if tasks[taskType]?[indexPath.row].status == .comleted {
            tasks[taskType]?[indexPath.row].status = .planned
        }
        
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskType = sectionsTypesPosition[indexPath.section]
        guard var _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
        
        guard tasks[taskType]?[indexPath.row].status == .comleted else {
            return nil
        }
        
        
        let action = UIContextualAction(style: .normal, title: "Не выполнена") { _, _, _ in
            self.tasks[taskType]![indexPath.row].status = .planned
            tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [action])
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
