Class {
	#name : #RBMetaclass,
	#superclass : #RBAbstractClass,
	#category : #'Refactoring-Core-Model'
}

{ #category : #'instance creation' }
RBMetaclass class >> existingNamed: aSymbol [ 
	^(self named: aSymbol)
		realName: aSymbol;
		yourself
]

{ #category : #'instance creation' }
RBMetaclass class >> named: aSymbol [ 
	^(self new)
		name: aSymbol;
		yourself
]

{ #category : #accessing }
RBMetaclass >> allClassVariableNames [
	^ self theNonMetaClass allClassVariableNames
]

{ #category : #accessing }
RBMetaclass >> allPoolDictionaryNames [
	^ self theNonMetaClass allPoolDictionaryNames
]

{ #category : #testing }
RBMetaclass >> directlyDefinesClassVariable: aString [ 
	^ self theNonMetaClass directlyDefinesClassVariable: aString
]

{ #category : #testing }
RBMetaclass >> directlyDefinesPoolDictionary: aString [ 
	^ self theNonMetaClass directlyDefinesPoolDictionary: aString
]

{ #category : #testing }
RBMetaclass >> isMeta [
	^true
]

{ #category : #printing }
RBMetaclass >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' class'
]

{ #category : #'initialize-release' }
RBMetaclass >> realName: aSymbol [ 
	self realClass: (Smalltalk globals at: aSymbol) classSide
]

{ #category : #printing }
RBMetaclass >> storeOn: aStream [ 
	super storeOn: aStream.
	aStream nextPutAll: ' class'
]

{ #category : #accessing }
RBMetaclass >> theMetaClass [
	^ self
]
