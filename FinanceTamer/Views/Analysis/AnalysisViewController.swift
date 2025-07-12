//
//  AnalysisViewController.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 08.07.2025.
//

import UIKit
import SwiftUI

class AnalysisViewController: UIViewController {
    private let direction: Direction
    private var viewModel: TransactionHistoryViewModel
    private var sortOption: TransactionHistoryViewModel.SortOption = .date_desc
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let headerLabel = UILabel()
    private let totalAmountLabel = UILabel()
    private let dateToPicker = CustomDatePickerView()
    private let dateFromPicker = CustomDatePickerView()
    
    init(direction: Direction) {
        self.direction = direction
        self.viewModel = TransactionHistoryViewModel(direction: direction)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        setupUI()
        updateTotalAmount()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        
        headerLabel.text = "Анализ"
        headerLabel.font = .systemFont(ofSize: 34, weight: .bold)
        headerLabel.textColor = .black
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "startCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "endCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sortCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sumCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "emptyCell")
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData() {
        Task {
            await viewModel.load()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateTotalAmount()
            }
        }
    }
    
    private func updateTotalAmount() {
        totalAmountLabel.text = "\(viewModel.total.formatted()) ₽"
    }
    
    @objc private func dateFromChanged(_ newDate: Date) {
        if newDate > viewModel.dateTo {
            viewModel.dateTo = newDate
            dateToPicker.date = newDate
        }
        viewModel.dateFrom = newDate
        loadData()
    }
    
    @objc private func dateToChanged(_ newDate: Date) {
        if newDate < viewModel.dateFrom {
            viewModel.dateFrom = newDate
            dateFromPicker.date = newDate
        }
        viewModel.dateTo = newDate
        loadData()
    }
    
    private func showSortOptions() {
        let alert = UIAlertController(title: "Показывать сначала", message: nil, preferredStyle: .actionSheet)
        
        TransactionHistoryViewModel.SortOption.allCases.forEach { option in
            let action = UIAlertAction(title: option.rawValue, style: .default) { _ in
                self.sortOption = option
                self.viewModel.sortTransactions(by: option)
                self.tableView.reloadData()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 4 : max(1, viewModel.extendedTransactions.count)
    }
    
    func tableView(_ tableView: UITableView, heightOfRowInSection section: Int) -> Int {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
                
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startCell", for: indexPath)
                cell.backgroundColor = .white
                configureDateCell(cell, title: "Период: начало", date: viewModel.dateFrom, selector: #selector(dateFromChanged))
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startCell", for: indexPath)
                cell.backgroundColor = .white
                configureDateCell(cell, title: "Период: конец", date: viewModel.dateTo, selector: #selector(dateToChanged))
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "sortCell", for: indexPath)
                cell.backgroundColor = .white
                configureSortCell(cell)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "sumCell", for: indexPath)
                cell.backgroundColor = .white
                configureTotalCell(cell)
                return cell
            default:
                fatalError("Unexpected row in section 0")
            }
        } else {
            if viewModel.extendedTransactions.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                cell.textLabel?.text = "Нет операций"
                cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
                cell.textLabel?.textAlignment = .center
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifier, for: indexPath) as! TransactionCell
                cell.total = viewModel.total
                let transaction = viewModel.extendedTransactions[indexPath.row]
                cell.configure(with: transaction)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            
        guard indexPath.section == 1, !viewModel.extendedTransactions.isEmpty else { return }
        
        let transaction = viewModel.extendedTransactions[indexPath.row]
        presentEditView(for: transaction)
    }
    
    private func configureDateCell(_ cell: UITableViewCell, title: String, date: Date, selector: Selector) {
        cell.textLabel?.text = title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black
        
        let datePicker: CustomDatePickerView
        switch selector {
        case #selector(dateFromChanged(_:)):
            datePicker = dateFromPicker
            datePicker.onDateChanged = dateFromChanged
        default:
            datePicker = dateToPicker
            datePicker.onDateChanged = dateToChanged
        }
        datePicker.date = date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.layer.cornerRadius = 6
        container.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
        ])
        
        cell.accessoryView = container
        cell.accessoryView?.frame.size = CGSize(width: 140, height: 34)
    }
    
    private func configureSortCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = "Сортировка"
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black
        
        let button = UIButton(type: .system)
        button.setTitle(sortOption.rawValue, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        
        button.backgroundColor = .lightGreen
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        
        cell.accessoryView = button
        cell.accessoryView?.frame.size = CGSize(width: 150, height: 34)
    }
    
    private func configureTotalCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = "Сумма"
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black

        totalAmountLabel.text = "\(viewModel.total.formatted()) ₽"
        totalAmountLabel.font = .systemFont(ofSize: 17, weight: .regular)
        
        cell.contentView.addSubview(totalAmountLabel)
        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            totalAmountLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            totalAmountLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        ])
    }
    
    @objc private func sortButtonTapped() {
        showSortOptions()
    }
    
    private func presentEditView(for transaction: ExtendedTransaction) {
        let editView = EditTransactionView(extendedTransaction: transaction) { [weak self] in
            self?.loadData()
        }

        let hostingController = UIHostingController(rootView: editView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Операции" : nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 40
    }
}

#Preview {
    AnalysisViewController(direction: .outcome)
}
