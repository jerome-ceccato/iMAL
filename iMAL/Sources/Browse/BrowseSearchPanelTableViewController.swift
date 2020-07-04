//
//  BrowseSearchPanelTableViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 11/04/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseSearchPanelTableViewController: UITableViewController {
    @IBOutlet var sortTextField: UITextField!
    @IBOutlet var typeTextField: UITextField!
    @IBOutlet var scoreTextField: UITextField!
    @IBOutlet var statusTextField: UITextField!
    @IBOutlet var ratingTextField: UITextField!
    @IBOutlet var genresTextField: UITextField!
    @IBOutlet var startDateTextField: UITextField!
    @IBOutlet var endDateTextField: UITextField!
    @IBOutlet var searchTextField: UITextField!
    
    @IBOutlet var allTextFields: [UITextField]!
    var allTextFieldOverlayButtons: [UIButton] = []
    
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    
    private var sortPickerView: UIPickerView!
    private var typePickerView: UIPickerView!
    private var scorePickerView: UIPickerView!
    private var statusPickerView: UIPickerView!
    private var ratingPickerView: UIPickerView!
    
    private var genresPickerView: BrowseSearchMultipleSelectionPickerView!

    private var startDatePickerView: UIDatePicker!
    private var endDatePickerView: UIDatePicker!
    
    weak var panelController: BrowseSearchPanelViewController!
    
    private var isKeyboardVisible: Bool = false
    
    var currentFilters = BrowseFilters()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.settings.backgroundColor.color
            self.tableView.backgroundColor = theme.settings.backgroundColor.color
            self.setupTableViewTheme(with: theme)
            self.setupFields()
        }
        setupFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unconfigureKeyboard()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            panelController.search(with: currentFilters)
            return
        }
        
        let fields: [[UITextField]] = [
            [sortTextField],
            [typeTextField,
             scoreTextField,
             statusTextField,
             ratingTextField,
             genresTextField,
             startDateTextField,
             endDateTextField,
             searchTextField]
        ]
        
        fields[safe: indexPath.section]?[safe: indexPath.row]?.becomeFirstResponder()
    }
}

// MARK: - Setup
private extension BrowseSearchPanelTableViewController {
    func setupFields() {
        let theme = ThemeManager.currentTheme
        setPlaceholders()
        
        allTextFields.forEach { textField in
            textField.tintColor = UIColor.clear
            textField.delegate = self
        }
        sortTextField.text = currentFilters.sortOrder.rawValue

        searchTextField.tintColor = theme.global.keyboardIndicator.color
        searchTextField.addTarget(self, action: #selector(dismissKeyboard), for: .editingDidEndOnExit)
        searchTextField.addTarget(self, action: #selector(filterTextFieldDidChange), for: .editingChanged)
        
        buildPickers()
        disableTextFieldSelection()
        
        let genres = panelController.entityKind == .anime ? Anime.genres : Manga.genres
        let filteredGenres = Settings.filterRatedX ? genres.filter { $0 != EntityRating.hentai.displayString } : genres
        let sortedGenres = filteredGenres.sorted()
        
        genresPickerView = BrowseSearchMultipleSelectionPickerView.create(with: sortedGenres, selected: [], delegate: self)
        
        genresTextField.inputView = genresPickerView
        genresTextField.inputAccessoryView = createPickerInputAccessoryView { toolbar in
            toolbar.items = [
                UIBarButtonItem(title: "Remove all", style: .plain, target: self, action: #selector(self.removeAllGenres)),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
            ]
        }
        
        if panelController.entityKind == .manga {
            startDateLabel.text = "Published after"
            endDateLabel.text = "Published before"
        }
    }
    
    func disableTextFieldSelection() {
        allTextFieldOverlayButtons = allTextFields.compactMap { field in
            guard field != searchTextField else {
                return nil
            }
            
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(nil, for: .normal)
            button.backgroundColor = UIColor.clear
            button.addTarget(self, action: #selector(self.textFieldOverlayButtonPressed(_:)), for: .touchUpInside)
            field.superview?.addSubviewPinnedToEdges(button)
            return button
        }
    }
    
    func setupTableView() {
        automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = .zero
        
        func makeEmptyView() -> UIView {
            let v = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 20)))
            v.alpha = 0
            return v
        }
        
        tableView.tableHeaderView = makeEmptyView()
        tableView.tableFooterView = makeEmptyView()
    }
    
    func setupTableViewTheme(with theme: Theme) {
        tableView.indicatorStyle = theme.global.scrollIndicators.style
        tableView.separatorColor = theme.separators.heavy.color
        
        
    }
    
    func setPlaceholders() {
        let theme = ThemeManager.currentTheme.genericView
        let placeholderAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: theme.labelText.color]
        let placeholders: [String?] = [
            nil,
            "all",
            "any",
            "any",
            "any",
            "all",
            nil,
            nil,
            "search terms"
        ]
        
        zip(allTextFields, placeholders).forEach { field, placeholder in
            if let placeholder = placeholder {
                field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
            }
        }
    }
    
    func buildPickers() {
        sortPickerView = createPicker(for: sortTextField)
        typePickerView = createPicker(for: typeTextField)
        scorePickerView = createPicker(for: scoreTextField)
        statusPickerView = createPicker(for: statusTextField)
        ratingPickerView = createPicker(for: ratingTextField)

        startDatePickerView = createDatePicker(for: startDateTextField)
        endDatePickerView = createDatePicker(for: endDateTextField)
        
        sortPickerView.selectRow(1, inComponent: 0, animated: false)
    }
    
    func createPicker(for field: UITextField) -> UIPickerView {
        let picker = DynamicPickerView(dynamic: true)
        picker.delegate = self
        picker.dataSource = self
        field.inputView = picker
        field.inputAccessoryView = createPickerInputAccessoryView { toolbar in
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
            ]
        }
        return picker
    }
    
    func createDatePicker(for field: UITextField) -> UIDatePicker {
        let picker = DynamicDatePickerView(dynamic: true)
        picker.datePickerMode = .date
        picker.date = Calendar.current.date(from: Calendar.current.dateComponents([.era, .year], from: Date())) ?? Date(timeIntervalSinceReferenceDate: 0)
        picker.addTarget(self, action: #selector(self.datePickerDidUpdate(_:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.currentDatePickerPressed(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        picker.addGestureRecognizer(tapGesture)
        
        field.inputView = picker
        field.inputAccessoryView = createPickerInputAccessoryView { toolbar in
            toolbar.items = [
                UIBarButtonItem(title: "Remove date", style: .plain, target: self, action: #selector(self.removeCurrentDate)),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
            ]
        }
        return picker
    }
    
    func createPickerInputAccessoryView(addAction: (UIToolbar) -> Void) -> UIToolbar {
        let theme = ThemeManager.currentTheme
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: AppDelegate.shared.viewPortSize.width, height: 44))
        toolbar.themeForHeader(with: theme)
        
        addAction(toolbar)
        return toolbar
    }
}

extension BrowseSearchPanelTableViewController: KeyboardDelegate {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func removeCurrentDate() {
        if startDateTextField.isFirstResponder {
            startDateTextField.text = nil
            currentFilters.period.start = nil
        }
        else if endDateTextField.isFirstResponder {
            endDateTextField.text = nil
            currentFilters.period.end = nil
        }
    }
    
    @objc func removeAllGenres() {
        genresPickerView.reset()
        multipleSelectionPickerView(genresPickerView, didUpdateWith: [])
    }
    
    @objc func textFieldOverlayButtonPressed(_ sender: UIButton) {
        if let index = allTextFieldOverlayButtons.index(of: sender), let textField = allTextFields[safe: index] {
            textField.becomeFirstResponder()
        }
    }
    
    func animateAlongSideKeyboardAnimation(appear: Bool, height: CGFloat) {
        if appear != isKeyboardVisible {
            isKeyboardVisible = appear
        }
    }
}

// MARK: - Data
private extension BrowseSearchPanelTableViewController {
    func pickerDisplayData(for picker: UIPickerView) -> [String] {
        let entityKind = panelController.entityKind!
        let labelAll = "All"
        let labelAny = "Any"
        
        switch picker {
        case sortPickerView:
            let items: [BrowseFilters.SortOrder] = [.title, .score, .members, .newest, .oldest]
            return items.map { $0.rawValue }
        
        case typePickerView:
            switch entityKind {
            case .anime:
                let items: [AnimeType] = [.tv, .ova, .movie, .special, .ona, .music]
                return [labelAll] + items.map { $0.displayString }
            case .manga:
                let items: [MangaType] = [.manga, .novel, .oneShot, .doujin, .manhwa, .manhua, .oel]
                return [labelAll] + items.map { $0.displayString }
            }
        
        case scorePickerView:
            return [labelAny] + Int.scoresDisplayStrings()[1 ..< 10]

        case statusPickerView:
            switch entityKind {
            case .anime:
                let items: [AnimeStatus] = [.airing, .finishedAiring, .notYetAired]
                return [labelAny] + items.map { $0.displayString }
            case .manga:
                let items: [MangaStatus] = [.publishing, .finished, .notYetPublished]
                return [labelAny] + items.map { $0.displayString }
            }
            
        case ratingPickerView:
            var items: [EntityRating] = [.allAges, .children, .teens, .violence, .mildNudity]
            if !Settings.filterRatedX {
                items.append(.hentai)
            }
            
            return [labelAny] + items.map { $0.displayString }

        default:
            return []
        }
    }
    
    func selectFilter(for picker: UIPickerView, row: Int) {
        let entityKind = panelController.entityKind!
        
        switch picker {
        case sortPickerView:
            let items: [BrowseFilters.SortOrder] = [.title, .score, .members, .newest, .oldest]
            currentFilters.sortOrder = items[row]
            
        case typePickerView:
            switch entityKind {
            case .anime:
                let items: [AnimeType] = [.tv, .ova, .movie, .special, .ona, .music]
                currentFilters.type = row == 0 ? nil : items[row - 1]
            case .manga:
                let items: [MangaType] = [.manga, .novel, .oneShot, .doujin, .manhwa, .manhua, .oel]
                currentFilters.type = row == 0 ? nil : items[row - 1]
            }
            
        case scorePickerView:
            currentFilters.score = row == 0 ? nil : row
            
        case statusPickerView:
            switch entityKind {
            case .anime:
                let items: [AnimeStatus] = [.airing, .finishedAiring, .notYetAired]
                currentFilters.status = row == 0 ? nil : items[row - 1]
            case .manga:
                let items: [MangaStatus] = [.publishing, .finished, .notYetPublished]
                currentFilters.status = row == 0 ? nil : items[row - 1]
            }
            
        case ratingPickerView:
            let items: [EntityRating] = [.allAges, .children, .teens, .violence, .mildNudity, .hentai]
            currentFilters.rating = row == 0 ? nil : items[row - 1]
            
        default:
            break
        }
    }
}

// MARK: - TableView Delegate
extension BrowseSearchPanelTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Hide rating cell on manga since it's not supported
        if panelController.entityKind == .manga && indexPath == IndexPath(row: 3, section: 1) {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}

// MARK: - TextField Delegate
extension BrowseSearchPanelTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.superview?.backgroundColor = ThemeManager.currentTheme.settings.cellSelectedColor.color
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.superview?.backgroundColor = ThemeManager.currentTheme.settings.cellBackgroundColor.color
    }
    
    @objc func filterTextFieldDidChange() {
        currentFilters.searchTerms = searchTextField.text ?? ""
    }
}

// MARK: - Picker Delegate
extension BrowseSearchPanelTableViewController: UIPickerViewDelegate, UIPickerViewDataSource, BrowseSearchMultipleSelectionDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDisplayData(for: pickerView).count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let theme = ThemeManager.currentTheme.picker
        return NSAttributedString(string: pickerDisplayData(for: pickerView)[row], attributes: [NSAttributedStringKey.foregroundColor: theme.text.color])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickers: [UIPickerView: UITextField] = [
            sortPickerView: sortTextField,
            typePickerView: typeTextField,
            scorePickerView: scoreTextField,
            statusPickerView: statusTextField,
            ratingPickerView: ratingTextField
        ]
        
        if pickerView != sortPickerView && row == 0 {
            pickers[pickerView]?.text = nil
        }
        else {
            pickers[pickerView]?.text = pickerDisplayData(for: pickerView)[row]
        }
        selectFilter(for: pickerView, row: row)
    }
    
    @objc func currentDatePickerPressed(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let active = [startDateTextField, endDateTextField].index(where: { $0.isFirstResponder }) {
                let picker = [startDatePickerView, endDatePickerView][active]!
                datePickerDidUpdate(picker)
            }
        }
    }
    
    @objc func datePickerDidUpdate(_ pickerView: UIDatePicker) {
        if pickerView == startDatePickerView {
            startDateTextField.text = pickerView.date.shortDateDisplayString
            currentFilters.period.start = pickerView.date
        }
        else if pickerView == endDatePickerView {
            endDateTextField.text = pickerView.date.shortDateDisplayString
            currentFilters.period.end = pickerView.date
        }
    }
    
    func multipleSelectionPickerView(_ pickerView: BrowseSearchMultipleSelectionPickerView, didUpdateWith selected: [String]) {
        genresTextField.text = selected.joined(separator: ", ")
        currentFilters.genres = selected
    }
}

// MARK: - Gesture Recognizer Delegate
extension BrowseSearchPanelTableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
