
index.html: display.py head.html styles.css show-episodes/*
	python display.py --import head.html --css styles.css > index.html
