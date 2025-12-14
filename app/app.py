from flask import Flask, render_template, request
from prometheus_flask_exporter import PrometheusMetrices

app = Flask(__name__)
metrices = PrometheusMetrices(app)

def fibonacci(n):
    if n <= 0:
        return []
    elif n == 1:
        return [0]
    else:
        list_fib = [0, 1]
        while len(list_fib) < n:
            next_fib = list_fib[-1] + list_fib[-2]
            list_fib.append(next_fib)
        return list_fib

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        try:
            num = int(request.form.get('number'))
            result = fibonacci(num)
            return render_template('index.html', result=result)
        except (ValueError, TypeError):
            return render_template('index.html', error="Please enter a valid number.")
    return render_template('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)