(function() {
  function webglAvailable() {
		try {
			var canvas = document.createElement('canvas');
      return !! (window.WebGLRenderingContext && (canvas.getContext('webgl') || canvas.getContext('experimental-webgl')));
		} catch (e) {
			return false;
		}
  }

  var $shard3dContainer = document.getElementById('shard-3d-container');
  if (!$shard3dContainer || !webglAvailable()) return;

  var camera, scene, renderer, controls;

	function init() {
		// scene
		scene = new THREE.Scene();

		// camera
		camera = new THREE.PerspectiveCamera(50, $shard3dContainer.clientWidth / $shard3dContainer.clientHeight, 1, 5000);
		camera.position.set(80, 0, 0);

		// controls
    var $rotatableZone = $('#shard-3d-container')[0];
    var $zoomableZone = $('#shard-3d-container .zoomable-zone')[0];
		controls = new THREE.OrbitControls(camera, $rotatableZone, $zoomableZone);
		controls.enableZoom = true;
		controls.enablePan = false;
		controls.autoRotate = true;
		controls.minDistance = 10;
		controls.maxDistance = 250;
		controls.minPolarAngle = Math.PI / 4;
		controls.maxPolarAngle = Math.PI / 1.5;

		// lights
		var ambientLight = new THREE.AmbientLight(0xffffff, 1)
		scene.add(ambientLight);

		purpleSpotLight = new THREE.SpotLight(0x544ac7, 10);
		purpleSpotLight.position.set( -100, 100, 100 );
		purpleSpotLight.angle = Math.PI / 10;
		scene.add(purpleSpotLight);

		pinkSpotLight = new THREE.SpotLight(0xbc53d0, 10);
		pinkSpotLight.position.set(0, -100, 0);
		pinkSpotLight.angle = Math.PI / 10;
		scene.add(pinkSpotLight);

		// scene.add(new THREE.SpotLightHelper(purpleSpotLight));
		// scene.add(new THREE.SpotLightHelper(pinkSpotLight));

		// cubemap
		var path = 'assets/textures/';
		var format = '.jpg';
		var urls = [
			path + 'px' + format, path + 'nx' + format,
			path + 'py' + format, path + 'ny' + format,
			path + 'pz' + format, path + 'nz' + format,
		];

		// model material
		var refractionCube = new THREE.CubeTextureLoader().load(urls);
		refractionCube.mapping = THREE.CubeRefractionMapping;
		refractionCube.format = THREE.RGBFormat;
		var cubeMaterial = new THREE.MeshLambertMaterial({ color: 0x544ac7, envMap: refractionCube, refractionRatio: 0.6 });

		// model
		var objLoader = new THREE.OBJLoader();
		objLoader.setPath('assets/models/');
		objLoader.load('shard.obj', function (object) {
			var baseMesh = object.children[0];
			var shard = baseMesh.clone();
			shard.material = cubeMaterial;
			scene.add(shard);
		});

		// renderer
		renderer = new THREE.WebGLRenderer({ alpha: true });
		renderer.setPixelRatio(window.devicePixelRatio);
		renderer.setSize($shard3dContainer.clientWidth, $shard3dContainer.clientHeight);
		$shard3dContainer.appendChild(renderer.domElement);

		window.addEventListener('resize', onWindowResize, false);
	}

	function animate() {
		requestAnimationFrame(animate);
		render();
	}

	function render() {
		controls.update();
		renderer.render(scene, camera);
	}

	function onWindowResize() {
		camera.aspect = $shard3dContainer.clientWidth / $shard3dContainer.clientHeight;
		camera.updateProjectionMatrix();
		renderer.setSize($shard3dContainer.clientWidth, $shard3dContainer.clientHeight);
	}

	init();
	animate();
})();
