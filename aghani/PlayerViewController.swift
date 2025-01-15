import AVFoundation
import UIKit
import MediaPlayer

class PlayerViewController: UIViewController, AVAudioPlayerDelegate {

    public var position: Int = 0
    public var songs: [Song] = []
    private var isProcessingCommand: Bool = false
    
    @IBOutlet var holder: UIView!
    
    var player: AVAudioPlayer?
    var timer: Timer?
    
    // Time Labels
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0:00"
        return label
    }()
    
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0:00"
        return label
    }()
    
    // Progress Slider
    let progressSlider = UISlider()
    
    // Other UI elements...
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let songNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let playPauseButton = UIButton()
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if holder.subviews.count == 0 {
            configure()
        }
    }
    
    func configure() {
        // Setup player
        let song = songs[position]
        let urlString = Bundle.main.path(forResource: song.trackName, ofType: "mp3")
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            guard let urlString = urlString else { return }
            
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlString))
            player?.delegate = self  // Set the delegate
            player?.volume = 0.5
            player?.play()
        } catch {
            print("Error occurred")
        }
        
        // Configure Now Playing Info Center
        configureNowPlayingInfo(song: song)
        
        // Enable Remote Control Events
        setupRemoteTransportControls()
        
        // Setup UI elements
        albumImageView.frame = CGRect(x: 30, y: 30, width: holder.frame.size.width-60, height: holder.frame.size.width-60)
        albumImageView.image = UIImage(named: song.imageName)
        holder.addSubview(albumImageView)
        
        songNameLabel.frame = CGRect(x: 10, y: albumImageView.frame.size.height+10, width: holder.frame.size.width-20, height: 70)
        albumNameLabel.frame = CGRect(x: 10, y: albumImageView.frame.size.height+10+70, width: holder.frame.size.width-20, height: 70)
        artistNameLabel.frame = CGRect(x: 10, y: albumImageView.frame.size.height+10+140, width: holder.frame.size.width-20, height: 70)
        
        songNameLabel.text = song.name
        albumNameLabel.text = song.albumName
        artistNameLabel.text = song.artistName
        
        holder.addSubview(songNameLabel)
        holder.addSubview(albumNameLabel)
        holder.addSubview(artistNameLabel)
        
        // Player controls
        let nextButton = UIButton()
        let backButton = UIButton()
        
        let yPosition = artistNameLabel.frame.origin.y + 70 + 20
        let size: CGFloat = 70
        
        playPauseButton.frame = CGRect(x: (holder.frame.size.width - size) / 2.0, y: yPosition, width: size, height: size)
        nextButton.frame = CGRect(x: holder.frame.size.width - size - 20, y: yPosition, width: size, height: size)
        backButton.frame = CGRect(x: 20, y: yPosition, width: size, height: size)
        
        playPauseButton.addTarget(self, action: #selector(pressedPlayPauseButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(pressedNextButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(pressedBackButton), for: .touchUpInside)
        
        playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        backButton.setBackgroundImage(UIImage(systemName: "backward.fill"), for: .normal)
        nextButton.setBackgroundImage(UIImage(systemName: "forward.fill"), for: .normal)
        
        
        
        holder.addSubview(playPauseButton)
        holder.addSubview(nextButton)
        holder.addSubview(backButton)
        
        // Progress slider
        progressSlider.frame = CGRect(x: 20, y: holder.frame.size.height - 100, width: holder.frame.size.width - 40, height: 50)
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(player?.duration ?? 0)
        progressSlider.addTarget(self, action: #selector(didSlideProgressSlider(_:)), for: .valueChanged)
        holder.addSubview(progressSlider)
        
        // Time Labels
        currentTimeLabel.frame = CGRect(x: 20, y: progressSlider.frame.origin.y - 20, width: 50, height: 20)
        totalTimeLabel.frame = CGRect(x: holder.frame.size.width - 70, y: progressSlider.frame.origin.y - 20, width: 50, height: 20)
        
        currentTimeLabel.text = "0:00"
        totalTimeLabel.text = formatTime(player?.duration ?? 0)
        
        holder.addSubview(currentTimeLabel)
        holder.addSubview(totalTimeLabel)
        
        // Start a timer to update the progress slider and labels
        startTimer()
    }
    
    func configureNowPlayingInfo(song: Song) {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: song.name,
            MPMediaItemPropertyAlbumTitle: song.albumName,
            MPMediaItemPropertyArtist: song.artistName,
            MPMediaItemPropertyPlaybackDuration: player?.duration ?? 0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player?.currentTime ?? 0,
            MPNowPlayingInfoPropertyPlaybackRate: player?.isPlaying == true ? 1.0 : 0.0
        ]
        
        // Add album artwork
        if let image = UIImage(named: song.imageName) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play Command
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.player?.play()
            self.updateNowPlayingPlaybackRate(isPlaying: true)
            return .success
        }
        
        // Pause Command
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.player?.pause()
            self.updateNowPlayingPlaybackRate(isPlaying: false)
            return .success
        }
        
        // Next Command
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.pressedNextButton()
            return .success
        }
        
        // Previous Command
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.pressedBackButton()
            return .success
        }
        
        // Playback Position Change Command (for seeking)
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self.player?.currentTime = event.positionTime
            self.updateNowPlayingElapsedTime()
            return .success
        }
    }
    
    func updateNowPlayingPlaybackRate(isPlaying: Bool) {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime ?? 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateNowPlayingElapsedTime() {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime ?? 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressSlider), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateProgressSlider() {
        guard let player = player else { return }
        progressSlider.value = Float(player.currentTime)
        currentTimeLabel.text = formatTime(player.currentTime)
    }
    
    @objc func didSlideProgressSlider(_ slider: UISlider) {
        player?.currentTime = TimeInterval(slider.value)
        currentTimeLabel.text = formatTime(player?.currentTime ?? 0)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    @objc func pressedBackButton() {
        guard !isProcessingCommand else { return } // Prevent simultaneous commands
        isProcessingCommand = true
        
        position = (position - 1 + songs.count) % songs.count
        player?.stop()
        for subview in holder.subviews {
            subview.removeFromSuperview()
        }
        configure()
        configureNowPlayingInfo(song: songs[position])
        
        isProcessingCommand = false
    }
    
    @objc func pressedNextButton() {
        guard !isProcessingCommand else { return } // Prevent simultaneous commands
        isProcessingCommand = true
        
        position = (position + 1) % songs.count
        player?.stop()
        for subview in holder.subviews {
            subview.removeFromSuperview()
        }
        configure()
        configureNowPlayingInfo(song: songs[position])
        
        isProcessingCommand = false
    }
    
    @objc func pressedPlayPauseButton() {
        if player?.isPlaying == true {
            player?.pause()
            playPauseButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            UIView.animate(withDuration: 0.2) {
                self.albumImageView.frame = CGRect(x: 60, y: 60, width: self.holder.frame.size.width-120, height: self.holder.frame.size.width-120)
            }
        } else {
            player?.play()
            playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            UIView.animate(withDuration: 0.2) {
                self.albumImageView.frame = CGRect(x: 30, y: 30, width: self.holder.frame.size.width-60, height: self.holder.frame.size.width-60)
            }
        }
    }
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
        
        player?.stop()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Timer for updating slider and elapsed time
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.progressSlider.value = Float(player.currentTime / player.duration)
            self.currentTimeLabel.text = self.formatTime(player.currentTime)
            self.totalTimeLabel.text = self.formatTime(player.duration)
            self.updateNowPlayingElapsedTime()
        }
    }
    
    /*override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.stop()
        }
        stopTimer()
    }*/
}
