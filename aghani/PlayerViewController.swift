//
//  PlayerViewController.swift
//  aghani
//
//  Created by Abdulrahman Negmeldin on 2025-01-14.
//

import AVFoundation
import UIKit

class PlayerViewController: UIViewController {

    public var position: Int = 0
    public var songs: [Song] = []
    
    @IBOutlet var holder: UIView!
    
    var player: AVAudioPlayer?
    
    //UI elements
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let songNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 //line wrap
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 //line wrap
        return label
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 //line wrap
        return label
    }()
    
    let playPauseButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if holder.subviews.count == 0 {
            configure()
        }
    }
    
    func configure() {
        //setup player
        
        let song = songs[position]
        
        let urlString = Bundle.main.path(forResource: song.trackName, ofType: "mp3")
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            guard let urlString = urlString else {
                return
            }
            
            player = try AVAudioPlayer(contentsOf: URL(string: urlString)!)
            
            guard let player = player else {
                return
            }
            player.volume = 0.5
            
            
            player.play()
        }
        catch {
            print("error occurred")
        }
        //setup user interface elements
        
        //album cover
        albumImageView.frame = CGRect(x: 10,
                                      y: 10,
                                      width: holder.frame.size.width-20,
                                      height: holder.frame.size.width-20)
        
        albumImageView.image = UIImage(named: song.imageName)
        holder.addSubview(albumImageView)
        
        //labels: song name, album, artist
        songNameLabel.frame = CGRect(x: 10,
                                     y: albumImageView.frame.size.height+10,
                                      width: holder.frame.size.width-20,
                                      height: 70)
        
        albumNameLabel.frame = CGRect(x: 10,
                                      y: albumImageView.frame.size.height+10+70,
                                      width: holder.frame.size.width-20,
                                      height: 70)
        
        artistNameLabel.frame = CGRect(x: 10,
                                      y: albumImageView.frame.size.height+10+140,
                                      width: holder.frame.size.width-20,
                                      height: 70)
        
        songNameLabel.text = song.name
        albumNameLabel.text = song.albumName
        artistNameLabel.text = song.artistName
        
        holder.addSubview(songNameLabel)
        holder.addSubview(albumNameLabel)
        holder.addSubview(artistNameLabel)
        
        //player controls
        let nextButton = UIButton()
        let backButton = UIButton()
        
        //frame
        let yPosition = artistNameLabel.frame.origin.y + 70 + 20
        let size: CGFloat = 70
        
        playPauseButton.frame = CGRect(x: (holder.frame.size.width - size) / 2.0,
                                       y: yPosition,
                                       width: size,
                                       height:size)
        
        nextButton.frame = CGRect(x: holder.frame.size.width - size - 20,
                                  y: yPosition,
                                  width: size,
                                  height:size)
        
        backButton.frame = CGRect(x: 20,
                                  y: yPosition,
                                  width: size,
                                  height:size)
                                       
        
        //button actions
        playPauseButton.addTarget(self, action: #selector(pressedPlayPauseButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(pressedNextButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(pressedBackButton), for: .touchUpInside)

        
        
        //images & tints for buttons
        playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        backButton.setBackgroundImage(UIImage(systemName: "backward.fill"), for: .normal)
        nextButton.setBackgroundImage(UIImage(systemName: "forward.fill"), for: .normal)
        
        playPauseButton.tintColor = .black
        backButton.tintColor = .black
        nextButton.tintColor = .black
        //add to holder
        holder.addSubview(playPauseButton)
        holder.addSubview(nextButton)
        holder.addSubview(backButton)

        //slider for volume
        let slider = UISlider(frame: CGRect(x: 20,
                                            y: holder.frame.size.height-60,
                                            width: holder.frame.size.width-40,
                                            height: 50))
        
        slider.value = 0.5
        slider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        holder.addSubview(slider)
        
        
    }
    
    @objc func pressedBackButton() {
        if position > 0 {
            position -= 1
            player?.stop()
            for subview in holder.subviews {
                subview.removeFromSuperview()
            }
            configure()
        }
    }
    
    @objc func pressedNextButton() {
        if position < songs.count - 1 {
            position += 1
            player?.stop()
            for subview in holder.subviews {
                subview.removeFromSuperview()
            }
            configure()
        }
        
    }
    
    @objc func pressedPlayPauseButton() {
        if player?.isPlaying == true {
            //pause
            player?.pause()
            //show play button
            playPauseButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)

        }
        else {
            //play
            player?.play()
            //show pause button
            playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)

            
        }
        
    }
    
    @objc func didSlideSlider(_ slider: UISlider) {
        let value = slider.value
        player?.volume = value
        //adjust player volume
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let player = player {
            player.stop()
        }
    }

}
