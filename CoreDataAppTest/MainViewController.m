//
//  MainViewController.m
//  CoreDataAppTest
//
//  Created by Frank Regel on 26.03.14.
//  Copyright (c) 2014 Frank Regel. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "Person.h"
#import "Postleitzahl.h"

@interface MainViewController ()<UITextFieldDelegate>

@property NSManagedObjectContext *context;
@property UITextField *nameField;
@property UITextField *ageField;
@property UITextField *plzField;
@property NSArray *resultArray;
@property UITableView *resultTable;
@property Person *selectedPerson;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        AppDelegate *appReference = [[UIApplication sharedApplication] delegate];
        _context = appReference.managedObjectContext;
        
        _resultArray = @[];
        _selectedPerson = nil;
        
        _nameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 100, 320, 60)];
        _nameField.backgroundColor = [UIColor grayColor];
        [self.view addSubview:_nameField];
        _nameField.delegate = self;
        
        _ageField = [[UITextField alloc] initWithFrame:CGRectMake(0, 180, 320, 60)];
        [self.view addSubview:_ageField];
        _ageField.backgroundColor = [UIColor grayColor];
        _ageField.keyboardType = UIKeyboardTypeNumberPad;
        _ageField.delegate = self;
        
        
        _plzField = [[UITextField alloc] initWithFrame:CGRectMake(0, 260, 320, 60)];
        [self.view addSubview:_plzField];
        _plzField.backgroundColor = [UIColor grayColor];
        _plzField.delegate = self;
        
        
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 80, 44)];
        [saveButton setTitle:@"Speichern" forState:UIControlStateNormal];
        saveButton.backgroundColor = [UIColor grayColor];
        [saveButton addTarget:self action:@selector(saveNewPerson) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:saveButton];
        
        _resultTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 320, 320, 180)];
        [self.view addSubview:_resultTable];
        _resultTable.dataSource = self;
        _resultTable.delegate = self;
        
        [self loadPeople];
        
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (Postleitzahl *)getPostLeitZahlObjectWithString:(NSString *)plzString
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Postleitzahl"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(plz = %@)",plzString];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultArray = [_context executeFetchRequest:fetchRequest error:&error];
    
    if (resultArray.count >0)
    {
        return [resultArray objectAtIndex:0];
    }
    else
    {
        Postleitzahl *postLeitZahl = [NSEntityDescription insertNewObjectForEntityForName:@"Postleitzahl" inManagedObjectContext:_context];
        postLeitZahl.plz = plzString;
        return postLeitZahl;
    }
    
}

- (void)saveNewPerson
{
    
    if (_selectedPerson == nil)
    {
        Person *newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:_context];
        newPerson.name = _nameField.text;
        newPerson.age = [NSNumber numberWithInteger:[_ageField.text integerValue]];
        newPerson.plz = [self getPostLeitZahlObjectWithString:_plzField.text];
        
        
    }
    else
    {
        _selectedPerson.name = _nameField.text;
        _selectedPerson.age = [NSNumber numberWithInteger:[_ageField.text integerValue]];
        _selectedPerson.plz = [self getPostLeitZahlObjectWithString:_plzField.text];
        
        
    }

    
    NSError *error = nil;
    [_context save:&error];
    [self loadPeople];
    [_nameField resignFirstResponder];
    [_ageField resignFirstResponder];
    _nameField.text = @"";
    _ageField.text = @"";
    _plzField.text = @"";
    _selectedPerson = nil;
}

- (void)loadPeople
{
    NSError *error = nil;
    NSFetchRequest *loadFetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    _resultArray = [_context executeFetchRequest:loadFetch error:&error];
    [_resultTable reloadData];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    Person *onePerson = [_resultArray objectAtIndex:indexPath.row];
    cell.textLabel.text = onePerson.name;
    return cell;
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person *onePerson = [_resultArray objectAtIndex:indexPath.row];
    _nameField.text = onePerson.name;
    _ageField.text =  [onePerson.age stringValue];
    _selectedPerson = onePerson;
    Postleitzahl *postLeitZahl = (Postleitzahl *)onePerson.plz;
    _plzField.text = postLeitZahl.plz;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person *onePerson = [_resultArray objectAtIndex:indexPath.row];
    [self removePerson:onePerson];
}


- (void)removePerson:(Person *)deletePerson
{
    [_context deleteObject:deletePerson];
    [self loadPeople];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
