//
//  ViewController.swift
//  learn-app-swift-00
//
//  Created by 汪喆昊 on 2025/1/18.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    lazy var forYouFlow = ForYouList()
    
    override func loadView() {
        super.loadView()
        print("ted")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(forYouFlow)
        forYouFlow.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            let items = (0..<20).map {
                ForYouItem(
                    uid: String($0),
                    title: "title \($0)",
                    authorName: "author \($0)",
                    likeCount: 10,
                    cover: .init(width: 10, height: 10, url: "")
                )
            }
            self?.forYouFlow.addItems(items)
        }
    }
}
