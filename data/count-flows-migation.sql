SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'birth' and country_ascii = 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'doutorado' and country_ascii != 'brazil')
	GROUP BY country_ascii
	ORDER BY country_ascii
	LIMIT 50000;

// Quem fez doutorado fora
SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'birth' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'doutorado' and country_ascii != 'brazil')
	GROUP BY country_ascii
	ORDER BY country_ascii
	LIMIT 50000;

//TOTAL
SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'birth' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'doutorado' and country_ascii != 'brazil');
13.201

//Extrangeiro
SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'birth' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'doutorado' and country_ascii != 'brazil');
2.348

// Quem fez mestrado fora
SELECT country_ascii, count(country_ascii)
  FROM locationslatlon 
  WHERE kind = 'birth'  and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'mestrado' and country_ascii != 'brazil') 
  GROUP BY country_ascii
  ORDER BY country_ascii
  LIMIT 100000;

//TOTAL
SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'birth' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'mestrado' and country_ascii != 'brazil');
4.949

//Extrangeiro
SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'birth' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'doutorado' and country_ascii != 'brazil');
1.198

//Onde o pessoal nasceu
SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'birth' and country_ascii != 'brazil'
	GROUP BY country_ascii
	ORDER BY country_ascii;

//Total
SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'birth' and country_ascii != 'brazil'
	ORDER BY country_ascii;
9.601






// Quem é de fora fez doutorado aonde
SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'doutorado' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil')
	GROUP BY country_ascii
	ORDER BY country_ascii;

SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'doutorado' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil');
//6.507 - 6507/186317 - 4% (208.996 id16, mas com reg. doutor 89%)

SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'doutorado' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil');
//2.376 - 2376/6507 - 36%

//4.131 - 4131/6507 - 64%

// Quem é daqui fez doutorado aonde
SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'doutorado' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii = 'brazil')
	GROUP BY country_ascii
	ORDER BY country_ascii;

SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'doutorado' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii = 'brazil');
//10.909 - 10909/169436 - 7%

//158.527 - 158527/169436 - 93%

// Quem é de fora fez mestrado aonde
SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'mestrado' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil')
	GROUP BY country_ascii
	ORDER BY country_ascii;

SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'mestrado' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil');
//4.464 - 4464/170013 - 3%

SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'mestrado' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil');
//1.236 - 1236/4464 - 28%

//3.228 - 3228/4464 - 72%

// Quem é daqui fez mestrado aonde
SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'mestrado' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil')
	GROUP BY country_ascii
	ORDER BY country_ascii;

SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'mestrado' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii = 'brazil');
//3.840 - 3840/158775 - 3%

//154.935 - 154935/158775 - 97%


// Quem é de fora trabalha aonde
SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'work' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil')
	GROUP BY country_ascii
	ORDER BY country_ascii;

SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'work' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil');
//5.654 - 5654/147650 - 4%

SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'work' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil');
//877 - 877/5654 - 26%

//4.777 - 4777/5654 - 84%

// Quem é daqui trabalha aonde
SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'work' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii = 'brazil')
	GROUP BY country_ascii
	ORDER BY country_ascii;

SELECT count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'work' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii = 'brazil');
//827 - 877/134290 - 0,6%

//133.463 - 4777/134290 - 99,4%








//Quantos registros são de fora
SELECT count(country_ascii)
	FROM locationslatlon
	WHERE country_ascii != 'brazil'
//61279
//Quantos registros são daqui
//1007230

//Registros de brasileiro
SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind != 'birth' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii = 'brazil')
	GROUP BY country_ascii
	ORDER BY country_ascii;
//No Brasil 772741/805340 - 96%
//De Fora  - 4%

//distribuição por país e tipo
SELECT country_ascii, kind, count(country_ascii)
	FROM locationslatlon
	WHERE kind != 'birth' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii = 'brazil')
	GROUP BY country_ascii, kind
	ORDER BY country_ascii;

//distribuição por tipo fora
SELECT kind, count(kind)
	FROM locationslatlon
	WHERE kind != 'birth' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii = 'brazil')
	GROUP BY kind;

//Registros de extrangeiro
SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind != 'birth' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil')
	GROUP BY country_ascii
	ORDER BY country_ascii;
//No Brasil 17542/26182 - 67%
//De Fora  - 33%

//distribuição por país e tipo
SELECT country_ascii, kind, count(country_ascii)
	FROM locationslatlon
	WHERE kind != 'birth' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii != 'brazil')
	GROUP BY country_ascii, kind
	ORDER BY country_ascii;





//Quem fez alguma formação fora tende continuar as próximas fora?!?!	

SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'doutorado' and id16 in 
		(SELECT id16 FROM locationslatlon WHERE kind = 'mestrado' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii = 'brazil'))
	GROUP BY country_ascii
	ORDER BY country_ascii;

//Total 3389
//Fora 2224/3389 = 65%
//Aqui 1165/3389 = 35%


SELECT country_ascii, count(country_ascii)
	FROM locationslatlon
	WHERE kind = 'pos-doutorado' and id16 in 
		(SELECT id16 FROM locationslatlon WHERE kind = 'doutorado' and country_ascii != 'brazil' and id16 in (SELECT id16 FROM locationslatlon WHERE kind = 'birth' and country_ascii = 'brazil'))
	GROUP BY country_ascii
	ORDER BY country_ascii;

//Total 3767
//Fora 2305/3767 = 61%
//Aqui 1462/3767 = 39%


