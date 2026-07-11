import '../models/weekday.dart';
import '../models/place.dart';
import '../models/area.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/collection.dart';

final mockWeekdaysList = [
  const Weekday(id: 'w-1', name: 'Monday', sortOrder: 1),
  const Weekday(id: 'w-2', name: 'Tuesday', sortOrder: 2),
  const Weekday(id: 'w-3', name: 'Wednesday', sortOrder: 3),
  const Weekday(id: 'w-4', name: 'Thursday', sortOrder: 4),
  const Weekday(id: 'w-5', name: 'Friday', sortOrder: 5),
  const Weekday(id: 'w-6', name: 'Saturday', sortOrder: 6),
  const Weekday(id: 'w-7', name: 'Sunday', sortOrder: 7),
];

final mockPlacesList = [
  const Place(id: 'p-1', weekdayId: 'w-4', name: 'Melur'), // Thursday Place
  const Place(id: 'p-2', weekdayId: 'w-4', name: 'Othakadai'), // Thursday Place
  const Place(id: 'p-3', weekdayId: 'w-1', name: 'Goripalayam'), // Monday Place
  const Place(id: 'p-4', weekdayId: 'w-2', name: 'Thirunagar'), // Tuesday Place
];

final mockAreasList = [
  const Area(id: 'a-1', placeId: 'p-1', name: 'North Street'),
  const Area(id: 'a-2', placeId: 'p-1', name: 'Bazaar Lane'),
  const Area(id: 'a-3', placeId: 'p-2', name: 'NH Colony'),
  const Area(id: 'a-4', placeId: 'p-3', name: 'Mosque Road'),
  const Area(id: 'a-5', placeId: 'p-4', name: 'Station Road'),
];

final mockProductsList = [
  const Product(
    id: 'pr-1',
    sku: 'MIX-PRE-3J',
    name: 'Prestige Mixer Grinder 3 Jar',
    brand: 'Prestige',
    category: 'Kitchen Appliances',
    minimumStock: 5,
    stock: 12,
    price: 3200,
  ),
  const Product(
    id: 'pr-2',
    sku: 'IND-PHI-HD',
    name: 'Philips Induction Cooktop HD4928',
    brand: 'Philips',
    category: 'Kitchen Appliances',
    minimumStock: 3,
    stock: 8,
    price: 2800,
  ),
  const Product(
    id: 'pr-3',
    sku: 'REF-LG-190L',
    name: 'LG 190L Single Door Refrigerator',
    brand: 'LG',
    category: 'Home Appliances',
    minimumStock: 2,
    stock: 4,
    price: 16500,
  ),
  const Product(
    id: 'pr-4',
    sku: 'TV-SAM-32',
    name: 'Samsung 32-inch Smart LED TV',
    brand: 'Samsung',
    category: 'Electronics',
    minimumStock: 2,
    stock: 0, // OUT OF STOCK
    price: 14500,
  ),
  const Product(
    id: 'pr-5',
    sku: 'WM-IFB-7KG',
    name: 'IFB 7Kg Front Load Washing Machine',
    brand: 'IFB',
    category: 'Home Appliances',
    minimumStock: 1,
    stock: 3,
    price: 28500,
  ),
  const Product(
    id: 'pr-6',
    sku: 'IRO-USHA-1K',
    name: 'Usha Dry Iron 1000W',
    brand: 'Usha',
    category: 'Home Appliances',
    minimumStock: 10,
    stock: 25,
    price: 850,
  ),
];

final mockCustomersList = [
  const Customer(
    id: 'c-1',
    customerCode: 'C-001',
    name: 'Lakshmi Priya',
    phone: '9876543210',
    alternatePhone: '9876543211',
    address: '12, North Street, Melur, Madurai - 625106',
    landmark: 'Near Ganesha Temple',
    weekdayId: 'w-4', // Thursday
    placeId: 'p-1', // Melur
    areaId: 'a-1', // North Street
    sequenceNumber: 1,
    status: 'ACTIVE',
    guardianName: 'Ramanathan (Spouse)',
    dob: '15-08-1985',
    occupation: 'Homemaker',
    notes: 'Always pays in the morning. Likes Prestige brand.',
  ),
  const Customer(
    id: 'c-2',
    customerCode: 'C-002',
    name: 'Muthu Pandian',
    phone: '9443210987',
    address: '45B, Bazaar Lane, Melur, Madurai - 625106',
    landmark: 'Opposite Government School',
    weekdayId: 'w-4', // Thursday
    placeId: 'p-1', // Melur
    areaId: 'a-2', // Bazaar Lane
    sequenceNumber: 2,
    status: 'ACTIVE',
    guardianName: 'Chinnasamy (Father)',
    occupation: 'Shop Owner',
    notes: 'Busy during noon. Call before visiting.',
  ),
  const Customer(
    id: 'c-3',
    customerCode: 'C-003',
    name: 'Anitha Rajendran',
    phone: '9988776655',
    address: '8, NH Colony, Othakadai, Madurai - 625107',
    landmark: 'Beside Post Office',
    weekdayId: 'w-4', // Thursday
    placeId: 'p-2', // Othakadai
    areaId: 'a-3', // NH Colony
    sequenceNumber: 1,
    status: 'ACTIVE',
    guardianName: 'Rajendran (Spouse)',
    occupation: 'Teacher',
    notes: 'Check back after 5 PM.',
  ),
  const Customer(
    id: 'c-4',
    customerCode: 'C-004',
    name: 'Karthik Raja',
    phone: '9123456789',
    address: '15, Mosque Road, Goripalayam, Madurai - 625002',
    weekdayId: 'w-1', // Monday
    placeId: 'p-3',
    areaId: 'a-4',
    sequenceNumber: 1,
    status: 'ACTIVE',
    guardianName: 'Murugan (Father)',
    notes: 'No outstanding balance.',
  ),
  const Customer(
    id: 'c-5',
    customerCode: 'C-005',
    name: 'Selvi Murugesan',
    phone: '9554433221',
    address: '22, Station Road, Thirunagar, Madurai - 625006',
    weekdayId: 'w-2', // Tuesday
    placeId: 'p-4',
    areaId: 'a-5',
    sequenceNumber: 1,
    status: 'DO_NOT_VISIT', // Overdue/Flagged
    guardianName: 'Murugesan (Spouse)',
    notes: 'Payment dispute. Flagged do not visit.',
  ),
  const Customer(
    id: 'c-6',
    customerCode: 'C-006',
    name: 'Rahim Khan',
    phone: '9888877777',
    address: '3, Mosque Road, Goripalayam, Madurai - 625002',
    weekdayId: 'w-1', // Monday
    placeId: 'p-3',
    areaId: 'a-4',
    sequenceNumber: 2,
    status: 'ACTIVE',
    notes: 'Small outstanding, pays regularly.',
  ),
  const Customer(
    id: 'c-7',
    customerCode: 'C-007',
    name: 'Meena Subramanian',
    phone: '9777766666',
    address: '56, North Street, Melur, Madurai - 625106',
    weekdayId: 'w-4', // Thursday
    placeId: 'p-1',
    areaId: 'a-1',
    sequenceNumber: 3,
    status: 'ACTIVE',
    notes: 'Newly added customer.',
  ),
  const Customer(
    id: 'c-8',
    customerCode: 'C-008',
    name: 'Venkatesan Alagar',
    phone: '9666655555',
    address: '102, NH Colony, Othakadai, Madurai - 625107',
    weekdayId: 'w-4', // Thursday
    placeId: 'p-2',
    areaId: 'a-3',
    sequenceNumber: 2,
    status: 'ACTIVE',
    notes: 'Prefers credit sales.',
  ),
];

final mockSalesList = [
  // Lakshmi Priya (c-1): bought Refrigerator, price 16500, advance 5000, financed 11500
  Sale(
    id: 's-1',
    customerId: 'c-1',
    saleDatetime: DateTime.now().subtract(const Duration(days: 15)),
    saleType: 'CREDIT',
    totalAmount: 16500,
    advanceAmount: 5000,
    financedAmount: 11500,
    soldBy: 'Ramesh (Collector)',
  ),
  // Lakshmi Priya (c-1): bought Mixer Grinder, price 3200, advance 3200, financed 0 (Ready Sale)
  Sale(
    id: 's-2',
    customerId: 'c-1',
    saleDatetime: DateTime.now().subtract(const Duration(days: 8)),
    saleType: 'READY',
    totalAmount: 3200,
    advanceAmount: 3200,
    financedAmount: 0,
    soldBy: 'Ramesh (Collector)',
  ),
  // Muthu Pandian (c-2): bought Induction Cooktop, price 2800, advance 500, financed 2300
  Sale(
    id: 's-3',
    customerId: 'c-2',
    saleDatetime: DateTime.now().subtract(const Duration(days: 20)),
    saleType: 'CREDIT',
    totalAmount: 2800,
    advanceAmount: 500,
    financedAmount: 2300,
    soldBy: 'Ramesh (Collector)',
  ),
  // Anitha Rajendran (c-3): bought Washing Machine, price 28500, advance 8500, financed 20000
  Sale(
    id: 's-4',
    customerId: 'c-3',
    saleDatetime: DateTime.now().subtract(const Duration(days: 30)),
    saleType: 'CREDIT',
    totalAmount: 28500,
    advanceAmount: 8500,
    financedAmount: 20000,
    soldBy: 'Ramesh (Collector)',
  ),
  // Rahim Khan (c-6): bought Dry Iron, price 850, advance 0, financed 850
  Sale(
    id: 's-5',
    customerId: 'c-6',
    saleDatetime: DateTime.now().subtract(const Duration(days: 5)),
    saleType: 'CREDIT',
    totalAmount: 850,
    advanceAmount: 0,
    financedAmount: 850,
    soldBy: 'Kumar (Owner)',
  ),
];

final mockCollectionsList = [
  // Lakshmi Priya (c-1): Paid 1500 (reducing 11500 -> 10000)
  Collection(
    id: 'col-1',
    customerId: 'c-1',
    visitDatetime: DateTime.now().subtract(const Duration(days: 7)),
    status: 'PAYMENT',
    amount: 1500,
    collectedBy: 'Ramesh (Collector)',
  ),
  // Lakshmi Priya (c-1): Carry forward (outstanding remains 10000)
  Collection(
    id: 'col-2',
    customerId: 'c-1',
    visitDatetime: DateTime.now().subtract(const Duration(hours: 4)),
    status: 'CARRY_FORWARD',
    amount: 0,
    reason: 'Husband not in town, will pay in evening',
    collectedBy: 'Ramesh (Collector)',
  ),
  // Lakshmi Priya (c-1): Partial payment of 200 today (outstanding 10000 -> 9800)
  Collection(
    id: 'col-3',
    customerId: 'c-1',
    visitDatetime: DateTime.now().subtract(const Duration(hours: 2)),
    status: 'PARTIAL_PAYMENT',
    amount: 200,
    reason: 'Will pay remaining in evening visit',
    collectedBy: 'Ramesh (Collector)',
  ),
  // Muthu Pandian (c-2): Paid 500 (reducing 2300 -> 1800)
  Collection(
    id: 'col-4',
    customerId: 'c-2',
    visitDatetime: DateTime.now().subtract(const Duration(days: 10)),
    status: 'PAYMENT',
    amount: 500,
    collectedBy: 'Ramesh (Collector)',
  ),
  // Anitha Rajendran (c-3): Carry forward
  Collection(
    id: 'col-5',
    customerId: 'c-3',
    visitDatetime: DateTime.now().subtract(const Duration(days: 6)),
    status: 'CARRY_FORWARD',
    amount: 0,
    reason: 'Salary delayed, check next week',
    collectedBy: 'Ramesh (Collector)',
  ),
];
