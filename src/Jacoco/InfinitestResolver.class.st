Class {
	#name : #InfinitestResolver,
	#superclass : #InfinitestParser,
	#category : #'Jacoco-Import'
}

{ #category : #accessing }
InfinitestResolver >> changedClass [
	^ super changedClass ==> [ :coll | '::' join: (((coll allButLast: '.class' size) substrings: '/') allButFirst: 3) ]
]

{ #category : #accessing }
InfinitestResolver >> changedClassAndDependencies [
	^ super changedClassAndDependencies ==> [ :coll | coll first -> (coll fourth ifNil: [ #() ]) ]
]

{ #category : #accessing }
InfinitestResolver >> dependency [
	^ super dependency ==> [ :coll | '::' join: (coll second substrings: '.') ]
]
