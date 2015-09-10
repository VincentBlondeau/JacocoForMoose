Class {
	#name : #InfinitestResolver,
	#superclass : #InfinitestParser,
	#category : #'Infinitest-Core'
}

{ #category : #accessing }
InfinitestResolver >> changedClass [
	^ super changedClass ==> [ :coll | '::' join: (((coll allButLast: '.class' size) substrings: '/') allButFirst: 7) ]
]

{ #category : #accessing }
InfinitestResolver >> changedClassAndDependencies [
	^ super changedClassAndDependencies ==> [ :coll | coll first -> (coll fourth ifNil: [ #() ]) ]
]

{ #category : #accessing }
InfinitestResolver >> dependency [
	^ super dependency ==> [ :coll | '::' join: (coll second substrings: '.') ]
]
