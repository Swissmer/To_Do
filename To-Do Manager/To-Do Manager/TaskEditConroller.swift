import UIKit

class TaskEditConroller: UITableViewController {
    
    // параметры задачи
    var taskText: String = ""
    var taskType: TaskPriority = .normal
    var taskStatus: TaskStatus = .planned
    
    var doAfterEdit: ((String, TaskPriority, TaskStatus) -> Void)?
    
    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskStatusSwitch: UISwitch!

    private var taskTitles: [TaskPriority: String] = [
        .high: "Важная",
        .normal: "Текущая"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if taskStatus == .comleted {
            taskStatusSwitch.isOn = true
        }
        
        taskTitle.text = taskText
        taskTypeLabel.text = taskTitles[taskType]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskTypeScreen" {
            
            // ссылка на контроллер
            let destionation = segue.destination as! TaskTypeController
            
            destionation.selectedType = taskType
            destionation.doAfterTypeSelected = { [unowned self] selectedType in
                taskType = selectedType
                
                taskTypeLabel.text = taskTitles[taskType]
                
            }
            
        }
    }
    
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        // получаем актуальные значения
         let title = taskTitle?.text ?? ""
         let type = taskType
        let status: TaskStatus = taskStatusSwitch.isOn ? .comleted : .planned
         // вызываем обработчик
         doAfterEdit?(title, type, status)
         // возвращаемся к предыдущему экрану
         navigationController?.popViewController(animated: true)
    }
}
