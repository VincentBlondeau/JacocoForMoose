Extension { #name : #FAMIXClass }

{ #category : #'*Jacoco' }
FAMIXClass >> innerClasses [
	^( self methods flatCollect: [:m |(m classes collect: #innerClasses) addAll:  m classes ] )
]

{ #category : #'*Jacoco' }
FAMIXClass >> innerMethods [
	^ self innerClasses flatCollect: #methods
]
