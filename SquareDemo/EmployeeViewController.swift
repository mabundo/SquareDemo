/*
 * Copyright 2015 shrtlist.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit

class EmployeeViewController : UITableViewController, UISplitViewControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var jobTitleLabel: UILabel?
    @IBOutlet weak var dateOfBirthLabel: UILabel?
    @IBOutlet weak var yearsEmployedLabel: UILabel?
    @IBOutlet weak var photoImageView: UIImageView?
    
    var employee: Employee? {
        didSet {
            configureView()
        }
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    // MARK: View configuration

    func clearView() {
        nameLabel.text = nil
        jobTitleLabel.text = nil
        dateOfBirthLabel.text = nil
        yearsEmployedLabel.text = nil
        photoImageView.image = nil
    }

    func configureView() {
        // Update the user interface for the detail item.
        
        if (employee) {
            nameLabel.text = employee.name
            jobTitleLabel.text = employee.jobTitle

            let dateFormatter: NSDateFormatter?
            
            if (dateFormatter == nil)
            {
                dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            }
            
            let dateOfBirth = dateFormatter.stringFromDate(employee.dateOfBirth)
            
            dateOfBirthLabel.text = dateOfBirth
            yearsEmployedLabel.text = NSString(format: "%d", employee.yearsEmployed)
            photoImageView.image = UIImage(data: employee.photo)
        }
        else {
            clearView()
        }
        
        tableView.reloadData()
    }

    // MARK: UISplitViewControllerDelegate protocol conformance

    func splitViewController(svc: UISplitViewController, willHideViewController aViewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController pc: UIPopoverController) {
        barButtonItem.title = NSLocalizedString("Employees", comment: "Employees")
        navigationItem.setLeftBarButtonItem(barButtonItem, animated: true)
    }

    func splitViewController(svc: UISplitViewController, willShowViewController aViewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem) {
        // Called when the view is shown again in the split view.
        navigationItem.setLeftBarButtonItem(nil, animated: true)
    }

}
