//
//  SettingsExportViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 31/05/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit
import AlamofireImage
import AEXML

class SettingsExportTableViewController: SettingsBaseTableViewController {
    enum ExportStyle {
        case raw
        case malXML
    }
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    var items: [UserDataCache.UserData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Export lists"
        
        applyTheme { [unowned self] theme in
            self.titleLabel.textColor = theme.genericView.warningText.color
            self.contentLabel.textColor = theme.genericView.importantText.color
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsExportTableViewCell", for: indexPath) as! SettingsExportTableViewCell
        
        cell.fill(with: items[indexPath.section])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        DispatchQueue.main.async {
            self.export(userData: self.items[indexPath.section])
        }
    }
}

private extension SettingsExportTableViewController {
    func updateData() {
        items = UserDataCache.allUserData()
        tableView.reloadData()
    }
    
    func pickExportStyle(completion: @escaping (ExportStyle) -> Void) {
        let alert = UIAlertController(title: "Export", message: "Choose your export method. \"Raw\" will export everything iMAL stores, and \"MAL Export format\" will export your lists like MAL's website would, letting you import them in other services", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Raw", style: .default, handler: { _ in
            DispatchQueue.main.async {
                completion(.raw)
            }
        }))
        alert.addAction(UIAlertAction(title: "MAL Export format", style: .default, handler: { _ in
            DispatchQueue.main.async {
                completion(.malXML)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func exportTemporaryURL(with name: String) -> URL {
       return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
    }
    
    func export(userData: UserDataCache.UserData) {
        guard userData.animeList != nil || userData.mangaList != nil else {
            return
        }
        
        pickExportStyle { style in
            var items: [URL] = []
            
            switch style {
            case .raw:
                if let animeList = userData.animeList, let exportURL = self.exportRaw(list: animeList, filename: "\(userData.username)-animelist-imal.json") {
                    items.append(exportURL)
                }
                if let mangaList = userData.mangaList, let exportURL = self.exportRaw(list: mangaList, filename: "\(userData.username)-mangalist-imal.json") {
                    items.append(exportURL)
                }
            case .malXML:
                if let animelist = userData.animeList, let exportURL = self.exportXML(list: animelist, entityName: "anime", username: userData.username, filename: "\(userData.username)-animelist-imal-compat.xml") {
                    items.append(exportURL)
                }
                if let mangaList = userData.mangaList, let exportURL = self.exportXML(list: mangaList, entityName: "manga", username: userData.username, filename: "\(userData.username)-mangalist-imal-compat.xml") {
                    items.append(exportURL)
                }
            }
            
            if !items.isEmpty {
                let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func exportRaw<T: IndexableList & Codable>(list: T, filename: String) -> URL? {
        do {
            let fileURL = exportTemporaryURL(with: filename)
            let data = try JSONEncoder().encode(list)
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        }
        catch {
            print(error)
        }
        return nil
    }
    
    func exportXML<T: IndexableList>(list: T, entityName: String, username: String, filename: String) -> URL? {
        let xml = AEXMLDocument()
        let root = xml.addChild(name: "my\(entityName)list")
        
        let myInfo = root.addChild(name: "myinfo")
        myInfo.addChild(name: "user_name", value: username)
        
        let CDATAEncode = { (data: String) in data }
        for entity in list.items {
            let child = root.addChild(name: entityName)
            
            let seriesPrefix = entityName == "anime" ? "series" : "manga"
            
            child.addChild(name: "\(seriesPrefix)_\(entityName)db_id", value: "\(entity.series.identifier)")
            child.addChild(name: "\(seriesPrefix)_title", value: CDATAEncode(entity.series.name))
            child.addChild(name: "\(seriesPrefix)_type", value: entity.series.type.displayString)

            child.addChild(name: "my_start_date", value: entity.startDate?.shortDateAPIString ?? "0000-00-00")
            child.addChild(name: "my_finish_date", value: entity.endDate?.shortDateAPIString ?? "0000-00-00")
            child.addChild(name: "my_score", value: "\(entity.score)")
            child.addChild(name: "my_status", value: entity.statusDisplayString)
            child.addChild(name: "my_tags", value: entity.tags.joined(separator: ", "))
            
            if let anime = entity as? UserAnime {
                child.addChild(name: "\(seriesPrefix)_episodes", value: "\(anime.animeSeries.episodes)")
                child.addChild(name: "my_watched_episodes", value: "\(anime.watchedEpisodes)")
                child.addChild(name: "my_rewatch_value", value: anime.restarting ? "1" : nil)
            }
            else if let manga = entity as? UserManga {
                child.addChild(name: "\(seriesPrefix)_volumes", value: "\(manga.mangaSeries.volumes)")
                child.addChild(name: "\(seriesPrefix)_chapters", value: "\(manga.mangaSeries.chapters)")
                child.addChild(name: "my_read_volumes", value: "\(manga.readVolumes)")
                child.addChild(name: "my_read_chapters", value: "\(manga.readChapters)")
                child.addChild(name: "my_reread_value", value: manga.restarting ? "1" : nil)
            }
        }
     
        do {
            let fileURL = exportTemporaryURL(with: filename)
            try xml.xml.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        }
        catch {
            print(error)
        }
        return nil
    }
}
