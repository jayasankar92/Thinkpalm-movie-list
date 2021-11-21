//
//  ViewController.swift
//  Thinkpalm ios test
//
//  Created by Arun Aravindakshan on 20/11/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    var movieContent = [Content]()
    var page = 1
    var isPageRefreshing:Bool = false

    private let spacing:CGFloat = 15.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        movieCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "MovieCollectionViewCell")

        if let localData = self.readLocalFile(forName: "CONTENTLISTINGPAGE-PAGE1") {
            self.parse(jsonData: localData)
        }
    }

    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode(Page.self,
                                                       from: jsonData)
            
            print("Title: ", decodedData.page.title)
            print("Description: ", decodedData.page.totalContentItems)
            print("===================================")
            movieContent.append(contentsOf: decodedData.page.contentItems.content)
            print(movieContent)
            DispatchQueue.main.async {
                self.movieCollectionView.reloadData()
                self.isPageRefreshing = false
            }
        } catch let error as NSError{
            print("decode error",error)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.movieCollectionView.contentOffset.y >= (self.movieCollectionView.contentSize.height - self.movieCollectionView.bounds.size.height)) {
            if !isPageRefreshing {
                isPageRefreshing = true
                print(page)
                page = page + 1
                if let localData = self.readLocalFile(forName:String(format: "CONTENTLISTINGPAGE-PAGE%d", page)) {
                    self.parse(jsonData: localData)
                }
            }
        }
    }
    
}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        cell.movieImageView.image = UIImage.init(named: movieContent[indexPath.item].posterImage)
        cell.movieName.text = movieContent[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 3
                let spacingBetweenCells:CGFloat = 0
                
                let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
                
                if let collection = self.movieCollectionView{
                    let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
                    return CGSize(width: width, height: width * 2)
                }else{
                    return CGSize(width: 0, height: 0)
                }
    }
}

