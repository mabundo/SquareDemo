/*
 * Copyright 2015 shrtlist.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
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

import CoreData
import UIKit

class MasterViewController : UITableViewController, NSFetchedResultsControllerDelegate {

    var employeeViewController: EmployeeViewController?
    var managedObjectContext: NSManagedObjectContext?
    lazy var fetchedResultsController: NSFetchedResultsController? = {
        
        var _fetchedResultsController: NSFetchedResultsController?

        if let moc = self.managedObjectContext {
            // Set up the fetched results controller.
            // Create the fetch request for the entity.
            let fetchRequest = NSFetchRequest()
            
            // Edit the entity name as appropriate.
            let entity = NSEntityDescription.entityForName("Employee", inManagedObjectContext: moc)
            fetchRequest.entity = entity
            
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
            
            // Sort by name in ascending order.
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Edit the section name key path and cache name if appropriate.
            // nil for section name key path means "no sections".
            _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "Master")
            
            // Set ourselves as delegate
            _fetchedResultsController?.delegate = self
            
            do {
                // Perform the fetch
                try _fetchedResultsController?.performFetch()
            }
            catch {
                print(error)
            }
        }
        
        return _fetchedResultsController
    }()
    
    private var selectedEmployee: Employee?

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Employees", comment: "Employees")

        // Do any additional setup after loading the view, typically from a nib.
        //employeeViewController = (EmployeeViewController *)splitViewController.viewControllers.last] topViewController]
        employeeViewController = navigationController?.topViewController as? EmployeeViewController

        // Load the sample data
        loadData()

        // Set up the Edit bar button item.
        navigationItem.leftBarButtonItem = editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        clearsSelectionOnViewWillAppear = (splitViewController?.collapsed)!
        
        super.viewWillAppear(animated)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Check the segue identifier
        if segue.identifier == "showDetail" {
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let employeeViewController = navigationController.topViewController as! EmployeeViewController
            if let _ = employeeViewController.view {
                employeeViewController.employee = selectedEmployee
            }
        }
    }

    // MARK: Deinitialization

    deinit {
        fetchedResultsController?.delegate = nil
    }

    // MARK: Target-action method
    
    @IBAction func refresh() {
        loadData()
    }

    // MARK: UITableViewDataSource protocol conformance
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (fetchedResultsController?.sections?.count)!
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController?.sections?[section]

        return (sectionInfo?.numberOfObjects)!
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        
        if let employee = fetchedResultsController?.objectAtIndexPath(indexPath) as! Employee? {
            // Get the employee from the fetchedResultsController
            configureCell(cell!, forEmployee: employee)
        }

        return cell!
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            do {
                // Delete the managed object for the given index path
                let context = fetchedResultsController?.managedObjectContext
            
                context?.deleteObject((fetchedResultsController?.objectAtIndexPath(indexPath))! as! NSManagedObject)
                
                try context?.save()
            }
            catch {
                print (error)
            }
            
            employeeViewController?.employee = nil
        }   
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // The table view should not be re-orderable.
        return false
    }

    // MARK: UITableViewDelegate protocol conformance

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (selectedEmployee == nil) {
            selectedEmployee = fetchedResultsController?.objectAtIndexPath(indexPath) as? Employee
        }
        else {
            selectedEmployee = nil
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        performSegueWithIdentifier("showDetail", sender: self)
    }

    // MARK: NSFetchedResultsControllerDelegate protocol conformance

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)

        case NSFetchedResultsChangeType.Move:
            print("nothing")
            
        case NSFetchedResultsChangeType.Update:
            print("nothing")
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case NSFetchedResultsChangeType.Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                
            case NSFetchedResultsChangeType.Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                
            case NSFetchedResultsChangeType.Update:
                tableView.cellForRowAtIndexPath(indexPath!)
            
            case NSFetchedResultsChangeType.Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    // MARK: Set cell properties with employee info
    func configureCell(cell: UITableViewCell, forEmployee employee: Employee) {
        cell.textLabel?.text = employee.name
        cell.detailTextLabel?.text = employee.jobTitle
        
        // Create the UIImage from the employee photo data.
        let image = UIImage(data: employee.photo)

        cell.imageView?.image = image
    }

    // MARK: Data load

    // For this demo, repopulate the data store by deleting and recreating all Employee managed objects.
    func loadData() {
        if let context = fetchedResultsController?.managedObjectContext {
        
            // Set up a fetch request to get all Employee managed objects
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("Employee", inManagedObjectContext: context)
            
            do {
                let result = try context.executeFetchRequest(fetchRequest)
            
                // Delete all managed objects
                for employee in result {
                    context.deleteObject(employee as! NSManagedObject)
                }
                
                if let image = UIImage(named: "icon-default-person") {
                    if let imageData = UIImagePNGRepresentation(image) {
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        
                        // Create new managed objects
                        
                        let employee1 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee1.name = "John Appleseed"
                        employee1.jobTitle = "Software Engineer - iOS"
                        employee1.dateOfBirth = dateFormatter.dateFromString("01/26/1978")!
                        employee1.yearsEmployed = 1
                        employee1.photo = imageData
                        
                        let employee2 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee2.name = "Ellen Roth"
                        employee2.jobTitle = "Software Engineer - Android"
                        employee2.dateOfBirth = dateFormatter.dateFromString("04/15/1985")!
                        employee2.yearsEmployed = 3
                        employee2.photo = imageData
                        
                        let employee3 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee3.name = "Zachary Wong"
                        employee3.jobTitle = "Product Manager"
                        employee3.dateOfBirth = dateFormatter.dateFromString("11/04/1986")!
                        employee3.yearsEmployed = 2
                        employee3.photo = imageData
                        
                        let employee4 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee4.name = "Cynthia Mala"
                        employee4.jobTitle = "Project Manager"
                        employee4.dateOfBirth = dateFormatter.dateFromString("03/14/1989")!
                        employee4.yearsEmployed = 2
                        employee4.photo = imageData

                        let employee5 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee5.name = "John Ross"
                        employee5.jobTitle = "Software Engineer - iOS"
                        employee5.dateOfBirth = dateFormatter.dateFromString("07/14/1972")!
                        employee5.yearsEmployed = 3
                        employee5.photo = imageData
                        
                        let employee6 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee6.name = "Russ Joy"
                        employee6.jobTitle = "Software Engineer - Android"
                        employee6.dateOfBirth = dateFormatter.dateFromString("05/24/1985")!
                        employee6.yearsEmployed = 3
                        employee6.photo = imageData
                        
                        let employee7 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee7.name = "Suzy Chen"
                        employee7.jobTitle = "Manager"
                        employee7.dateOfBirth = dateFormatter.dateFromString("07/14/1972")!
                        employee7.yearsEmployed = 3
                        employee7.photo = imageData
                        
                        let employee8 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee8.name = "Vincent Dorn"
                        employee8.jobTitle = "Software Engineer - iOS"
                        employee8.dateOfBirth = dateFormatter.dateFromString("07/22/1990")!
                        employee8.yearsEmployed = 1
                        employee8.photo = imageData
                        
                        let employee9 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee9.name = "Srini Chagar"
                        employee9.jobTitle = "Product Manager"
                        employee9.dateOfBirth = dateFormatter.dateFromString("08/01/1969")!
                        employee9.yearsEmployed = 3
                        employee9.photo = imageData
                        
                        let employee10 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee10.name = "Lynn Hopi"
                        employee10.jobTitle = "Software Engineer - Android"
                        employee10.dateOfBirth = dateFormatter.dateFromString("02/22/1978")!
                        employee10.yearsEmployed = 3
                        employee10.photo = imageData
                        
                        let employee11 = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context) as! Employee
                        employee11.name = "Krista Venkata"
                        employee11.jobTitle = "Product Manager"
                        employee11.dateOfBirth = dateFormatter.dateFromString("09/05/1986")!
                        employee11.yearsEmployed = 2
                        employee11.photo = imageData
                        
                        try context.save()
                    }
                }
            }
            catch {
                print(error)
            }
        }
    }

}
