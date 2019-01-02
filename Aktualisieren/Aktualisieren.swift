//
//  File.swift
//  App_Normal_feature
//
//  Created by zhaofei on 2018/12/28.
//  Copyright © 2018 zhaofei. All rights reserved.
//

import UIKit

let currentInstalledVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
private var skippedVersionKey = "skippedVersionKey"
private var nextTimeUpdateKey = "nextTimeUpdateKey"
private var customNewVersionView_conatiner_padding: CGFloat = 32
private var customNewVersionView_content_padding: CGFloat = 12
private var customNewVersionView_button_height: CGFloat = 44
private var customNewVersionView_content_max_height: CGFloat = 300


class Aktualisieren: UIView {
    
    lazy var titleLabel = { () -> UILabel in
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.text = "新版本提示"
        return titleLabel
    }()
    
    lazy var contentLabel = { () -> UITextView in
        let contentLabel = UITextView()
        contentLabel.isEditable = false
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        return contentLabel
    }()
    
    lazy var skipBtn = { () -> UIButton in
        let skipBtn = UIButton()
        skipBtn.translatesAutoresizingMaskIntoConstraints = false
        skipBtn.setTitleColor(UIColor.black, for: .normal)
        skipBtn.setTitle("跳过", for: .normal)
        return skipBtn
    }()
    
    lazy var nextTimeBtn = { () -> UIButton in
        let nextTimeBtn = UIButton()
        nextTimeBtn.translatesAutoresizingMaskIntoConstraints = false
        nextTimeBtn.setTitleColor(UIColor.black, for: .normal)
        nextTimeBtn.setTitle("下次更新", for: .normal)
        return nextTimeBtn
    }()
    
    lazy var updateBtn = { () -> UIButton in
        let updateBtn = UIButton()
        updateBtn.translatesAutoresizingMaskIntoConstraints = false
        updateBtn.setTitleColor(UIColor.black, for: .normal)
        updateBtn.setTitle("立即更新", for: .normal)
        return updateBtn
    }()
    
    func generateSepratorLine() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.lightGray
        return v
    }

    private var contentHeightConstraint: NSLayoutConstraint!
    private var kwindow: UIWindow?
    private var appId = ""
    private var currentAppStoreVersion = ""
    private var appStoreReleaseNotes = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.5
        addSubview(bgView)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentLabel)
        
        let skip_top_line = generateSepratorLine()
        containerView.addSubview(skip_top_line)
        
        containerView.addSubview(skipBtn)
        
        let skip_bottom_line = generateSepratorLine()
        containerView.addSubview(skip_bottom_line)
        
        containerView.addSubview(nextTimeBtn)
        
        let nextTime_bottom_line = generateSepratorLine()
        containerView.addSubview(nextTime_bottom_line)
        
        containerView.addSubview(updateBtn)
        
        // events
        skipBtn.addTarget(self, action: #selector(self.handleSkip), for: .touchUpInside)
        nextTimeBtn.addTarget(self, action: #selector(self.handleNextTime), for: .touchUpInside)
        updateBtn.addTarget(self, action: #selector(self.handleUpdate), for: .touchUpInside)
        
        // Layout
        let bgView_top = bgView.topAnchor.constraint(equalTo: topAnchor)
        let bgView_left = bgView.leftAnchor.constraint(equalTo: leftAnchor)
        let bgView_right = bgView.rightAnchor.constraint(equalTo: rightAnchor)
        let bgView_bottom = bgView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([bgView_top, bgView_left, bgView_right, bgView_bottom])
        
        let conatinerView_centerY = containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10)
        let containerView_left = containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: customNewVersionView_conatiner_padding)
        let containerView_right = containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -customNewVersionView_conatiner_padding)
        NSLayoutConstraint.activate([containerView_left, containerView_right, conatinerView_centerY])
        
        // title
        let title_centerX = titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        let title_top = titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20)
        NSLayoutConstraint.activate([title_top, title_centerX])
        
        // content
        let content_label_top = contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12)
        let content_label_left = contentLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: customNewVersionView_content_padding)
        let content_label_right = contentLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -customNewVersionView_content_padding)
        let content_label_height_less = contentLabel.heightAnchor.constraint(lessThanOrEqualToConstant: customNewVersionView_content_max_height)
        contentHeightConstraint = content_label_height_less
        NSLayoutConstraint.activate([content_label_top, content_label_left, content_label_right, content_label_height_less])
        
        // skip_top_line
        let s_top_line_top = skip_top_line.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12)
        let s_top_line_left = skip_top_line.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0)
        let s_top_line_right = skip_top_line.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0)
        let s_top_line_height = skip_top_line.heightAnchor.constraint(equalToConstant: 1)
        NSLayoutConstraint.activate([s_top_line_top, s_top_line_left, s_top_line_right, s_top_line_height])
        
        // skip
        let skip_top = skipBtn.topAnchor.constraint(equalTo: skip_top_line.bottomAnchor, constant: 0)
        let skip_left = skipBtn.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0)
        let skip_right = skipBtn.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0)
        let skip_height = skipBtn.heightAnchor.constraint(equalToConstant: customNewVersionView_button_height)
        NSLayoutConstraint.activate([skip_top, skip_left, skip_right, skip_height])
        
        // skip_bottom_line
        let s_bottom_line_top = skip_bottom_line.topAnchor.constraint(equalTo: skipBtn.bottomAnchor, constant: 0)
        let s_bottom_line_left = skip_bottom_line.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0)
        let s_bottom_line_right = skip_bottom_line.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0)
        let s_bottom_line_height = skip_bottom_line.heightAnchor.constraint(equalToConstant: 1)
        NSLayoutConstraint.activate([s_bottom_line_top, s_bottom_line_left, s_bottom_line_right, s_bottom_line_height])
        
        // nextTime
        let nextTime_top = nextTimeBtn.topAnchor.constraint(equalTo: skipBtn.bottomAnchor, constant: 0)
        let nextTime_left = nextTimeBtn.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0)
        let nextTime_right = nextTimeBtn.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0)
        let nextTime_height = nextTimeBtn.heightAnchor.constraint(equalToConstant: customNewVersionView_button_height)
        NSLayoutConstraint.activate([nextTime_top, nextTime_left, nextTime_right, nextTime_height])
        
        // nextTime_bottom_line
        let nextTime_bottom_line_top = nextTime_bottom_line.topAnchor.constraint(equalTo: nextTimeBtn.bottomAnchor, constant: 0)
        let nextTime_bottom_line_left = nextTime_bottom_line.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0)
        let nextTime_bottom_line_right = nextTime_bottom_line.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0)
        let nextTime_bottom_line_height = nextTime_bottom_line.heightAnchor.constraint(equalToConstant: 1)
        NSLayoutConstraint.activate([nextTime_bottom_line_top, nextTime_bottom_line_left, nextTime_bottom_line_right, nextTime_bottom_line_height])
        
        // update
        let update_top = updateBtn.topAnchor.constraint(equalTo: nextTime_bottom_line.bottomAnchor, constant: 0)
        let update_left = updateBtn.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0)
        let update_right = updateBtn.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0)
        let update_height = updateBtn.heightAnchor.constraint(equalToConstant: customNewVersionView_button_height)
        NSLayoutConstraint.activate([update_top, update_left, update_right, update_height])
        
        let container_bottom = containerView.bottomAnchor.constraint(equalTo: updateBtn.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([container_bottom])

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 计算文字高度
        let width = UIScreen.main.bounds.size.width - customNewVersionView_conatiner_padding * 2 - customNewVersionView_content_padding * 2 - contentLabel.textContainerInset.left - contentLabel.textContainerInset.right
        
        let attrStr = NSAttributedString(string: contentLabel.text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        let size = attrStr.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
        
        let height = size.height + contentLabel.textContainerInset.top + contentLabel.textContainerInset.bottom
        
        if height < customNewVersionView_content_max_height {
            contentHeightConstraint.constant = height
        }
    }
    
    class func checkNewVersion(withAppId appId: String?) {
        
        guard let aId = appId else { return }
        
        let session = URLSession.shared
        
        let urlString = "https://itunes.apple.com/cn/lookup?id=\(aId)"
        let url = URL(string: urlString)
        guard let u = url else { return }
        
        let task = session.dataTask(with: u) { (data, response, error) in
            if error != nil {
                print("dataTaskError: \(error?.localizedDescription ?? "")")
                return
            }
            guard let da = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: da, options: .mutableLeaves) as? [AnyHashable: Any]
                
                guard let j = json else { return }
                
                guard let results = j["results"] as? [Any] else { return }
                guard let firstObjc = results.first as? [AnyHashable : Any] else { return }
                
                guard let currentAppStoreVersion = firstObjc["version"] as? String else { return }
                guard let appStoreReleaseNotes = firstObjc["releaseNotes"] as? String else { return }
                
                if checkIsNewVersion(currentAppStoreVersion) {
                    self.alert(withAppId: aId, newVersion: currentAppStoreVersion, releaseNotes: appStoreReleaseNotes)
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    class func checkIsNewVersion(_ currentAppStoreVersion: String?) -> Bool {
        // check appStoreVersion > installedVersion
        var isNew: Bool = currentInstalledVersion.compare(currentAppStoreVersion ?? "", options: .numeric, range: nil, locale: .current) == .orderedAscending
        
        // check skipVersion != installedVersion
        let skipedVersion = UserDefaults.standard.object(forKey: skippedVersionKey) as? String
        if (skipedVersion == currentAppStoreVersion) {
            isNew = false
        }
        return isNew
    }
    
    class func alert(withAppId appId: String, newVersion: String, releaseNotes: String) {
        DispatchQueue.main.async(execute: {
            let newWindow = UIWindow(frame: UIScreen.main.bounds)
            let v = Aktualisieren()
            v.frame = UIScreen.main.bounds
            v.kwindow = newWindow
            
            v.appId = appId
            v.currentAppStoreVersion = newVersion
            v.appStoreReleaseNotes = releaseNotes
            v.contentLabel.text = releaseNotes
            v.kwindow?.addSubview(v)
            
            newWindow.makeKeyAndVisible()
        })
    }
    
    @objc func handleSkip() {
        // save current AppStore version in userDefault
        UserDefaults.standard.set(currentAppStoreVersion, forKey: skippedVersionKey)
        UserDefaults.standard.synchronize()
        dismiss()
    }
    
    @objc func handleNextTime() {
        dismiss()
    }
    
    @objc func handleUpdate() {
        dismiss()
        launchAppStore()
    }
    
    func dismiss() {
        removeFromSuperview()
        kwindow?.resignKey()
        kwindow = nil
    }
    
    func launchAppStore() {
        let iTunesString = "https://itunes.apple.com/cn/app/id\(appId)"
        let iTunesURL = URL(string: iTunesString)
        
        DispatchQueue.main.async(execute: {
            if #available(iOS 10.0, *) {
                if let url = iTunesURL {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                if let url = iTunesURL {
                    UIApplication.shared.openURL(url)
                }
            }
        })
    }

    
}
