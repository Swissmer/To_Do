import UIKit

class TaskListController: UITableViewController {
    
    // хранилище задач
    var taskStorage: TasksStorageProtocol = TasksStorage()
    // коллекция задач
    var tasks: [TaskPriority: [TaskProtocol]] = [:] {
        didSet {
            for (tasksGroupPriority, tasksGroup) in tasks {
                tasks[tasksGroupPriority] = tasksGroup.sorted{ task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
            
            var savingArray: [TaskProtocol] = []
            tasks.forEach { _, value in
                savingArray += value
            }
            taskStorage.saveTasks(savingArray)
//            print("выгрузили:", taskStorage.loadTasks())
        }
    }
    // секции
    var sectionsTypesPosition: [TaskPriority] = [.high, .normal]
    // порядок отображения задач
    var tasksStatusPosition: [TaskStatus] = [.planned, .comleted]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // загрузка задач
        // кнопка активации режима редактирования
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    // получение списка задач, из разбор и установка в свойство tasks
    func setTasks(_ tasksCollection: [TaskProtocol]) {
        // подготовка коллекции с задачами
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        // загрузка и разбор задач из хранилища
        tasksCollection.forEach { task in
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
        
        let action = UIContextualAction(style: .normal, title: "Не выполнена") { _, _, _ in
            self.tasks[taskType]![indexPath.row].status = .planned
            tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        
        let actionEditInstance = UIContextualAction(style: .normal, title: "Изменить") { _, _, _ in
            // загрузка сцены со storyboard
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TaskEditController") as! TaskEditConroller
            // передача значений редактируемой задачи
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            // передача обработчика для сохранения задачи
            editScreen.doAfterEdit = { [unowned self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                tasks[taskType]![indexPath.row] = editedTask
                tableView.reloadData()
            }
            // переход к экрану редактирования
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
        
        // изменяем цвет фона кнопки с действием
        actionEditInstance.backgroundColor = .darkGray
        
        // создаем объект, описывающий доступные действия
        // в зависимости от статуса задачи будет отображено 1 или 2 действия
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .comleted {
            actionsConfiguration = UISwipeActionsConfiguration(actions:
                                                                [action, actionEditInstance])
        } else {
            actionsConfiguration = UISwipeActionsConfiguration(actions:
                                                                [actionEditInstance])
        }
        return actionsConfiguration
    }
    
    // режим редактирования (обработка нажатия)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        
        tasks[taskType]?.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Реализация перемещения ячеек
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
        let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
        
        // безопастное извлечение
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        
        // удаление из старого места
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        
        // добавление в новое место
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        
        //  обновление данных таблицы
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditConroller
            destination.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
}
