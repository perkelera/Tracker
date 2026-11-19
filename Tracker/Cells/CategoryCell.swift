import UIKit

final class CategoryCell: UITableViewCell {
    static let identifier = "CategoryCell"
    
    let titleLabel = UILabel()
    let checkmarkImageView = UIImageView()
    let separatorView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .systemGray6
        selectionStyle = .none
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = UIColor(red: 0.20, green: 0.45, blue: 0.91, alpha: 1.0)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.isHidden = true
        contentView.addSubview(checkmarkImageView)
        
        separatorView.backgroundColor = .separator
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(title: String, isSelected: Bool, isFirst: Bool, isLast: Bool, isSingle: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        if isSingle {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorView.isHidden = true
        } else if isFirst {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            separatorView.isHidden = false
        } else if isLast {
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorView.isHidden = true
        } else {
            layer.maskedCorners = []
            separatorView.isHidden = false
        }
    }
}
