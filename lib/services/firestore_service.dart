import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../utils/error_handler.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Generic document operations
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(collection).doc(docId).get();
      _logger.d('Retrieved document: $collection/$docId');
      return doc;
    } catch (e) {
      _logger.e('Failed to get document $collection/$docId: $e');
      throw ErrorHandler.handleFirestoreError(e);
    }
  }

  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
      _logger.d('Set document: $collection/$docId');
    } catch (e) {
      _logger.e('Failed to set document $collection/$docId: $e');
      throw ErrorHandler.handleFirestoreError(e);
    }
  }

  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
      _logger.d('Updated document: $collection/$docId');
    } catch (e) {
      _logger.e('Failed to update document $collection/$docId: $e');
      throw ErrorHandler.handleFirestoreError(e);
    }
  }

  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      _logger.d('Deleted document: $collection/$docId');
    } catch (e) {
      _logger.e('Failed to delete document $collection/$docId: $e');
      throw ErrorHandler.handleFirestoreError(e);
    }
  }

  // Query operations
  Future<QuerySnapshot> queryCollection(
    String collection, {
    QueryBuilder? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      QuerySnapshot snapshot = await query.get();
      _logger.d('Queried collection: $collection, found ${snapshot.docs.length} documents');
      return snapshot;
    } catch (e) {
      _logger.e('Failed to query collection $collection: $e');
      throw ErrorHandler.handleFirestoreError(e);
    }
  }

  // Real-time listeners
  Stream<DocumentSnapshot> documentStream(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot> collectionStream(
    String collection, {
    QueryBuilder? queryBuilder,
  }) {
    Query query = _firestore.collection(collection);
    
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    return query.snapshots();
  }

  // Batch operations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.set:
            batch.set(operation.reference, operation.data!);
            break;
          case BatchOperationType.update:
            batch.update(operation.reference, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(operation.reference);
            break;
        }
      }

      await batch.commit();
      _logger.d('Batch write completed with ${operations.length} operations');
    } catch (e) {
      _logger.e('Batch write failed: $e');
      throw ErrorHandler.handleFirestoreError(e);
    }
  }
}

// Helper types
typedef QueryBuilder = Query Function(Query query);

enum BatchOperationType { set, update, delete }

class BatchOperation {
  final BatchOperationType type;
  final DocumentReference reference;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.type,
    required this.reference,
    this.data,
  });
}