import 'demo_file.dart';

const documents = [
  DemoFile('Contract.pdf', DemoFileKind.pdf, size: '1.2 MB', folder: 'Work'),
  DemoFile('Notes.txt', DemoFileKind.text, size: '4 KB', folder: 'Documents'),
  DemoFile('Budget.xlsx', DemoFileKind.sheet, size: '86 KB', folder: 'Work'),
  DemoFile('Beach.jpg', DemoFileKind.image, size: '3.4 MB', folder: 'Photos'),
  DemoFile(
    'Backup.zip',
    DemoFileKind.archive,
    size: '240 MB',
    folder: 'Archive',
  ),
  DemoFile(
    'Invoice.pdf',
    DemoFileKind.pdf,
    size: '320 KB',
    folder: 'Work',
    isReadOnly: true,
  ),
  DemoFile(
    'Recipes.txt',
    DemoFileKind.text,
    size: '12 KB',
    folder: 'Documents',
  ),
  DemoFile(
    'Trip plan.xlsx',
    DemoFileKind.sheet,
    size: '40 KB',
    folder: 'Documents',
  ),
  DemoFile(
    'Mountains.jpg',
    DemoFileKind.image,
    size: '5.1 MB',
    folder: 'Photos',
  ),
  DemoFile(
    'Manual.pdf',
    DemoFileKind.pdf,
    size: '8.7 MB',
    folder: 'Documents',
    isReadOnly: true,
  ),
  DemoFile(
    'Photos 2025.zip',
    DemoFileKind.archive,
    size: '1.3 GB',
    folder: 'Archive',
  ),
  DemoFile('Ideas.txt', DemoFileKind.text, size: '2 KB', folder: 'Documents'),
];

/// The files shown in the grid above the list.
final recentFiles = documents.take(6).toList();

const folders = ['Documents', 'Work', 'Photos', 'Archive'];

const contacts = ['Anna', 'Boris', 'Chris', 'Diana', 'Emma'];
