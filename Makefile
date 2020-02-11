all:
	@echo "target: poly mlton clean"

db.so: db.c
	cc -shared -o db.so -fPIC db.c

poly: db.so
	polyc -o t-poly t.mlp
	env LD_LIBRARY_PATH=. ./t-poly

mlton:
	mlton -default-ann 'allowFFI true' -output t-mlton t.mlb db.c
	./t-mlton

clean:
	rm -f t-poly t-mlton db.so
