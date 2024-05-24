import Foundation

// требования к хранилищу
protocol TaskStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}

class TaskStorage: TaskStorageProtocol {
    func loadTasks() -> [TaskProtocol] {
        let test: [TaskProtocol] = [
            Task(title: "Найти работу", type: .high, status: .planned),
            Task(title: "Реализовать To-Do", type: .normal, status: .planned),
            Task(title: "Создать Git", type: .normal, status: .comleted)
        ]
        
        return test
    }
    
    func saveTasks(_ tasks: [TaskProtocol]) {}
}
