//
//  ViewController.swift
//  MusicProfile
//
//  Created by Tal Cohen on 22/04/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit
import PieCharts
import SwiftyJSON

class ViewController: UIViewController {
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var loaderAnimation: UIImageView!
    
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var subgenreLabel: UILabel!
    
    @IBOutlet weak var portraitView: UIView!
    @IBOutlet weak var landscapeView: UIView!
    @IBOutlet weak var pie: PieChart!
    @IBOutlet weak var detailedPie: PieChart!
    @IBOutlet weak var tableView: UITableView!
    
    var models = [PieSliceModel]()
    var playlist : [Song] {
        get {
            return AppData.shared.playlist
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showLoader()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "PlaylistTableViewCell", bundle: nil), forCellReuseIdentifier: "playlistCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = UIColor(white: 1, alpha: 0.5)
        
        self.landscapeView.isHidden = true
        self.setupPies { 
            self.setupPlaylist()
        }
    }
    
    func setupPies(completion: (()->())?) {
        self.pie.animDuration = 2
        self.detailedPie.animDuration = 3
        let textLayer = PieLineTextLayer()
        textLayer.settings.label.font = UIFont.systemFont(ofSize: 10, weight: 0)
        textLayer.settings.label.textColor = .white
        textLayer.settings.lineColor = .white
        textLayer.settings.label.textGenerator = { slice in
            
            return "\(AppData.shared.user.pie[slice.data.id].name)"
        }
        self.detailedPie.layers = [textLayer]
        
        APIManager.getUser(userId: "35", success: { user in
            AppData.shared.user = user
            DispatchQueue.main.async {
                self.detailedPie.models = user.pie.flatMap {
                    return PieSliceModel(value: $0.percentages, color: $0.color)
                }
                
                self.pie.models = user.categoriesPie.flatMap {
                    return PieSliceModel(value: $0.percentages, color: $0.color)
                }
            }
            completion?()
        }) { (error) in
            print("getUserFailed")
        }
    }
    
    func setupPlaylist() {
        let myUser = AppData.shared.user!
        APIManager.getPlaylist(userId: myUser.userId, startingGenre: myUser.randomSubgenre?.name ?? "random", success: { playlist in
            AppData.shared.playlist += playlist
            DispatchQueue.main.async { [unowned self] in
                self.hideLoader()
                self.tableView.reloadData()
                self.songTapped(song: self.playlist[0])
            }
            
        }) { (error) in
            print("getPlaylist failed")
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            if UIDevice.current.orientation.isLandscape {
                print("Landscape")
                self.landscapeView.isHidden = false
                self.portraitView.isHidden = true
            } else {
                print("Portrait")
                self.landscapeView.isHidden = true
                self.portraitView.isHidden = false
            }
        }, completion: nil)
    }
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }

}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! PlaylistTableViewCell
        cell.songLabel?.text = self.playlist[indexPath.row].songName
        cell.artistLabel.text = self.playlist[indexPath.row].artistName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = self.playlist[indexPath.item]
        self.songTapped(song: song)
    }
    
    func songTapped(song: Song) {
        self.songLabel.text = song.songName
        self.artistLabel.text = song.artistName
        self.subgenreLabel.text = song.genre
        let myVideoURL = URL(string: song.url)
    }
    
    func showLoader() {
        self.loaderView.isHidden = false
        var images = [UIImage]()
        let loaderImagesCount = 65
        for i in 0..<loaderImagesCount {
            let imageName = "smallLoader-\(i)"
            let image = UIImage(named: imageName)!
            images.append(image)
        }
        let gifFps = 30
        self.loaderAnimation.animationImages = images
        self.loaderAnimation.animationDuration = TimeInterval(loaderImagesCount/gifFps)
        self.loaderAnimation.startAnimating()
    }
    
    func hideLoader() {
        self.loaderAnimation.stopAnimating()
        self.loaderView.isHidden = true
    }
}
