import axios from "axios";
import applyCaseMiddleware from 'axios-case-converter'
import React, { useCallback, useState, useEffect } from "react"
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Modal from 'react-bootstrap/Modal';


const mapFormComponent= ({
  props
}) => {
  const [show, setShow] = useState(false);
  const [cityName, setCityName] = useState("");
  const [type, setType] = useState("");
  const [latDivision, setLatDivision] = useState(0);
  const [lngDivision, setLngDivision] = useState(0);
  const [fileName, setFileName] = useState("");

  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  const client = applyCaseMiddleware(
    axios.create({
      baseURL: '',
    }),
    options
  );

  const options = {
    ignoreHeaders: true,
  }

  const handleConfirmButton = () => {
    client
    .post(`maps`, {
        city_name: cityName,
        type: type,
        latDivision: latDivision,
        lngDivision: lngDivision,
        fileName: fileName
      }
    )
    .then(res => {
      console.log(res.data)
      alert("success");
    })

  };

  return (
    <div>
      <Form>
        <Form.Group className="mb-3" controlId="formBasicEmail">
          <Form.Label>市区町村名</Form.Label>
          <Form.Control type="text" placeholder="愛知県名古屋市中区" onChange={(e) => setCityName(e.target.value)}/>
        </Form.Group>

        <Form.Group className="mb-3" controlId="formBasicPassword">
          <Form.Label>対象type</Form.Label>
          <Form.Control type="text" placeholder="lodging" onChange={(e) => setType(e.target.value)}/>
        </Form.Group>

        <Form.Group className="mb-3" controlId="formBasicPassword">
          <Form.Label>lat_division値</Form.Label>
          <Form.Control type="text" placeholder="0.0006" onChange={(e) => setLatDivision(e.target.value)}/>
        </Form.Group>

        <Form.Group className="mb-3" controlId="formBasicPassword">
          <Form.Label>lng_division値</Form.Label>
          <Form.Control type="text" placeholder="0.0006" onChange={(e) => setLngDivision(e.target.value)}/>
        </Form.Group>

        <Form.Group className="mb-3" controlId="formBasicPassword">
          <Form.Label>出力するcsvファイル名</Form.Label>
          <Form.Control type="text" placeholder="sample.csv" onChange={(e) => setFileName(e.target.value)}/>
        </Form.Group>

        <Button className="mt-3" variant="success" type="Button" onClick={handleShow}>
          取得
        </Button>
      </Form>

      <Modal show={show} onHide={handleClose}>
        <Modal.Header closeButton>
          <Modal.Title>以下の内容でよろしいですか？</Modal.Title>
        </Modal.Header>
        <Modal.Body>{`${cityName}\n${type}\n${latDivision}\n${lngDivision}\n${fileName}`}</Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleClose}>
            キャンセル
          </Button>
          <Button variant="primary" onClick={handleConfirmButton}>
            確定
          </Button>
        </Modal.Footer>
      </Modal>
  </div>
  );
};

export default mapFormComponent;