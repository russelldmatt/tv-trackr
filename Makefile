
index.html: display.py head.html styles.css today.txt show-episodes/*
	python display.py --import head.html --css styles.css > index.html
