import Foundation
import UIKit

final class StatisticCardView: UIView {
    private let colors = Colors()
    private let gradientLayer = CAGradientLayer()
    private let borderMask = CAShapeLayer()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(value: Int) {
        valueLabel.text = "\(value)"
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        let insetBounds = bounds.insetBy(dx: 0.5, dy: 0.5)
        borderMask.path = UIBezierPath(roundedRect: insetBounds, cornerRadius: 16).cgPath
    }

    private func setupUI() {
        backgroundColor = colors.viewBackgroundColor
        layer.cornerRadius = 16

        valueLabel.textColor = colors.primaryTextColor
        titleLabel.textColor = colors.primaryTextColor

        gradientLayer.colors = [
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1.0).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1.0).cgColor,
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        borderMask.lineWidth = 1
        borderMask.fillColor = UIColor.clear.cgColor
        borderMask.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = borderMask
        layer.addSublayer(gradientLayer)

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 90),

            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
}
