import UIKit

class TaskTypeController: UITableViewController {
    
    typealias TypeCellDescrioption = (type: TaskPriority, title: String, description: String)
    
    private var taskTypesInformation: [TypeCellDescrioption] = [
        (type: .high, title: "Важная", description: "Такой тиg задач является наиболее приоритетным для выполнения. Все важные задачи выводятся в самом верху списка задач"),
        (type: .normal, title: "Текущая", description: "Задача с обычным приоритетом")
    ]
    
    var selectedType: TaskPriority = .normal
    
    var doAfterTypeSelected: ((TaskPriority) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // получение значение типа UINib, соответсвующее xib-файлу
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        // регистрация кастомной ячейки
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return taskTypesInformation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:
                            IndexPath) -> UITableViewCell {
        // 1. получение переиспользуемой кастомной ячейки по ее идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell",
                                                 for: indexPath) as! TaskTypeCell
        // 2. получаем текущий элемент, информация о котором должна быть выведена в строке
        let typeDescription = taskTypesInformation[indexPath.row]
        // 3. заполняем ячейку данными
        cell.typeTitle.text = typeDescription.title
        cell.typeDescription.text = typeDescription.description
        // 4. если тип является выбранным, то отмечаем галочкой
        if selectedType == typeDescription.type {
            cell.accessoryType = .checkmark
            // в ином случае снимаем отметку
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedType = taskTypesInformation[indexPath.row].type
        
        doAfterTypeSelected?(selectedType)
        
        navigationController?.popViewController(animated: true)
    }
}
