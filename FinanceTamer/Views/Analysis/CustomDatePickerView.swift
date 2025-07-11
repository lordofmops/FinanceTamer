//
//  CustomDatePickerView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 08.07.2025.
//

import UIKit

final class CustomDatePickerView: UIView {
    var onDateChanged: ((Date) -> Void)?

    var date: Date = Date() {
        didSet {
            updateDateLabel()
            datePicker.date = date
        }
    }

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGreen
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru")
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        updateDateLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        datePicker.alpha = 0.011
        datePicker.isUserInteractionEnabled = true
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        backgroundView.addSubview(dateLabel)
        addSubview(datePicker)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 34),

            dateLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -12),
            dateLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),

            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func updateDateLabel() {
        let formatter = DateFormatters.dayMonth
        dateLabel.text = formatter.string(from: date).capitalized
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.date = sender.date
        updateDateLabel()
        onDateChanged?(sender.date)
    }
}

#Preview {
    AnalysisViewController(direction: .outcome)
}
