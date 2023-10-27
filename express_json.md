# json communication over HTTP with expressjs

## usage

### setup

as a general rule of thumb, use express.json() BEFORE you do anything.
it's a statemachine, so anything defined before the express.json() that relies on the body will not work.

```js
const app = express();

app.use(express.json()); // Required to parse JSON data from POST requests

setup_solutions(app);
setup_todo(app);
```

### routing

we use the .json to automatically parse the body into a stringified JSON object.

```js
app.post('/example', (req, res) => {
  console.log('POST request to "/example"');
  console.log(req.body); // Access the posted data from req.body
  res.json(req.body); // Return the received data
});
```

just mutate the res object to modify the return to give nice JSON output.

## usage on the frontend

### fetch

here's an example of pinging a route on a server with express POST json.
we stringify it ourselves, and we parse with the .json() in the fetch api.

```js
const POST_to_server = (str, req_type) => {
  const url = `${get_base()}/list/${req_type}`; // Replace with your actual endpoint URL
  const message = JSON.stringify(list_message(str));
  
  console.log(message);

  console.log('POST request to url: ', url);

  fetch(url, {
    method: 'POST',
    headers: {
      // it just won't work without the right content-type.
      'Content-Type': 'application/json',
    },
    body: message,
  })
    .then(response => {
      response.json()
    }) // get the actual JSON JS object, not the string.
    // this should be the list array.
    .then(responseData => {
      // Handle the response data
      console.log('POST success: ', response);
      console.log(responseData);
      return responseData; // the JSON of the list
    })
    .catch(error => {
      // Handle any errors
      console.error('POST error');
      console.error('Error:', error);
      return null;
    });
}
```
