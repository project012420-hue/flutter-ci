import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Signaling {
  final _db = FirebaseFirestore.instance;

  Future<void> createSession(String code) async {
    await _db.collection('sessions').doc(code).set({});
  }

  Future<void> sendOffer(String code, RTCSessionDescription offer) async {
    await _db.collection('sessions').doc(code).set({
      'offer': {
        'sdp': offer.sdp,
        'type': offer.type,
      }
    }, SetOptions(merge: true));
  }

  Future<void> sendAnswer(String code, RTCSessionDescription answer) async {
    await _db.collection('sessions').doc(code).set({
      'answer': {
        'sdp': answer.sdp,
        'type': answer.type,
      }
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> listen(String code) {
    return _db.collection('sessions').doc(code).snapshots();
  }

  Future<void> sendCandidate(
      String code, String role, RTCIceCandidate candidate) async {
    await _db
        .collection('sessions')
        .doc(code)
        .collection('candidates_$role')
        .add(candidate.toMap());
  }

  Stream<QuerySnapshot> candidates(String code, String role) {
    return _db
        .collection('sessions')
        .doc(code)
        .collection('candidates_$role')
        .snapshots();
  }

  Future<void> deleteSession(String code) async {
    final sessionRef = _db.collection('sessions').doc(code);

    final hostCandidates = await sessionRef.collection('candidates_host').get();
    for (final doc in hostCandidates.docs) {
      await doc.reference.delete();
    }

    final viewerCandidates =
        await sessionRef.collection('candidates_viewer').get();
    for (final doc in viewerCandidates.docs) {
      await doc.reference.delete();
    }

    await sessionRef.delete();
  }
}
