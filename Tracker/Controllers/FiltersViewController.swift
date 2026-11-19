import UIKit

enum TrackerFilter: Int, CaseIterable {
    case all = 0
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("filters.all", comment: "")
        case .today:
            return NSLocalizedString("filters.today", comment: "")
        case .completed:
            return NSLocalizedString("filters.completed", comment: "")
        case .uncompleted:
            return NSLocalizedString("filters.uncompleted", comment: "")
        }
    }
}

final class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: FiltersViewControllerDelegate?
    var selectedFilter: TrackerFilter = .all

    private let colors = Colors()
    private let filters = TrackerFilter.allCases

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filters.title", comment: "")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.layer.cornerRadius = 16
        table.isScrollEnabled = false
        table.rowHeight = 75
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackgroundColor
        titleLabel.textColor = colors.primaryTextColor

        tableView.dataSource = self
        tableView.delegate = self

        setupViews()
    }

    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(filters.count * 75))
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "filterCell")
        let filter = filters[indexPath.row]

        cell.backgroundColor = colors.secondaryBackgroundColor
        cell.selectionStyle = .none
        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = colors.primaryTextColor
        cell.tintColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1.0)
        let shouldShowCheckmark = (filter == selectedFilter) && (filter == .completed || filter == .uncompleted)
        cell.accessoryType = shouldShowCheckmark ? .checkmark : .none
        if indexPath.row == filters.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosen = filters[indexPath.row]
        selectedFilter = chosen
        tableView.reloadData()
        delegate?.didSelectFilter(chosen)
        dismiss(animated: true)
    }
}
protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}
