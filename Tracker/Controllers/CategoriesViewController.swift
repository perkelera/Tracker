import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

final class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: CategoriesViewControllerDelegate?
    private let viewModel: CategoryViewModel
    
    let tableView = UITableView()
    let placeholderImage = UIImageView()
    let placeholderText = UILabel()
    let addCategoryButton = UIButton(type: .system)
    
    init(viewModel: CategoryViewModel = CategoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Категория"
        view.backgroundColor = .systemBackground
        navigationItem.setHidesBackButton(true, animated: false)
        
        setupViews()
        bindViewModel()
    }
    
    func setupViews() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        placeholderImage.image = UIImage(named: "star") ?? UIImage(systemName: "star")
        placeholderImage.contentMode = .scaleAspectFit
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderImage)
        
        placeholderText.text = "Привычки и события можно\nобъединить по смыслу"
        placeholderText.textAlignment = .center
        placeholderText.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderText.textColor = .label
        placeholderText.numberOfLines = 2
        placeholderText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderText)
        
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.setTitleColor(.white, for: .normal)
        addCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.backgroundColor = .black
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -40),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderText.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderText.centerXAnchor.constraint(equalTo: placeholderImage.centerXAnchor),
            placeholderText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.updatePlaceholder()
        }
        
        viewModel.onCategorySelected = { [weak self] category in
            self?.delegate?.didSelectCategory(category)
            self?.navigationController?.popViewController(animated: true)
        }
        
        updatePlaceholder()
    }
    
    func updatePlaceholder() {
        let isEmpty = viewModel.numberOfCategories == 0
        placeholderImage.isHidden = !isEmpty
        placeholderText.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    @objc func addCategoryTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] title in
            self?.viewModel.addNewCategory(title: title)
        }
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.category(at: indexPath.row)
        let isSelected = viewModel.isSelected(at: indexPath.row)
        let totalCount = viewModel.numberOfCategories
        
        let isSingle = totalCount == 1
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == totalCount - 1
        
        cell.configure(
            title: category.title,
            isSelected: isSelected,
            isFirst: isFirst,
            isLast: isLast,
            isSingle: isSingle
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
