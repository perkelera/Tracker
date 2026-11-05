import UIKit

final class NewCategoryViewController: UIViewController,UITextFieldDelegate {
    
    var onCategoryCreated: ((String) -> Void)?
    
    let nameTextField = UITextField()
    let doneButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая категория"
        view.backgroundColor = .systemBackground
        navigationItem.setHidesBackButton(true, animated: false)
        
        setupViews()
    }
    
    func setupViews() {
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
        nameTextField.placeholder = "Введите название категории"
        nameTextField.backgroundColor = .systemGray6
        nameTextField.layer.cornerRadius = 16
        nameTextField.font = .systemFont(ofSize: 17, weight: .regular)
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = .systemGray4
        doneButton.layer.cornerRadius = 16
        doneButton.isEnabled = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func textFieldDidChange() {
        let text = nameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        doneButton.isEnabled = !text.isEmpty
        doneButton.backgroundColor = !text.isEmpty ? .black : .systemGray4
    }
    
    @objc func doneTapped() {
        guard let text = nameTextField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return }
        onCategoryCreated?(text)
        navigationController?.popViewController(animated: true)
    }
}
