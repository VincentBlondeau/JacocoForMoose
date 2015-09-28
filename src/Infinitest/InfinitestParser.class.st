Class {
	#name : #InfinitestParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'changedClasses',
		'changedClass',
		'changedClassAndDependencies',
		'dependency',
		'javaDependencies'
	],
	#category : #'Infinitest-Core'
}

{ #category : #'as yet unclassified' }
InfinitestParser >> changedClass [
	^ '[' asParser negate plus flatten 
]

{ #category : #'as yet unclassified' }
InfinitestParser >> changedClassAndDependencies [
	^ changedClass , '[' asParser , #newline asParser star , javaDependencies optional , ']' asParser , #newline asParser star
]

{ #category : #'as yet unclassified' }
InfinitestParser >> changedClasses [
	^ changedClassAndDependencies star
]

{ #category : #grammar }
InfinitestParser >> dependency [
	^ #blank asParser , ',' asParser negate plus flatten  , ',' asParser , #newline asParser star
]

{ #category : #'as yet unclassified' }
InfinitestParser >> javaDependencies [
	^ dependency plus
]

{ #category : #accessing }
InfinitestParser >> start [
	^ changedClasses
]
