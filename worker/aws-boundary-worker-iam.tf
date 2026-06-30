############################################
# IAM for Boundary self-managed worker (EC2)
# - EC2 instance role (instance profile)
# - Discovery role (assumed by worker) for EC2 Describe*
############################################

data "aws_iam_policy_document" "boundary_worker_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "boundary_worker_role" {
  name               = "boundary-worker-runtime"
  assume_role_policy = data.aws_iam_policy_document.boundary_worker_trust.json

#lifecycle {
#    prevent_destroy = true
#  }
}

resource "aws_iam_instance_profile" "boundary_worker_instance_profile" {
  name = "boundary-worker-instance-profile"
  role = aws_iam_role.boundary_worker_role.name

  #lifecycle {
  #  prevent_destroy = true
  #}
}

# Trust: allow the worker role to assume the discovery role
data "aws_iam_policy_document" "boundary_discovery_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.boundary_worker_role.arn]
    }
  }
}

resource "aws_iam_role" "boundary_discovery_role" {
  name               = "boundary-aws-discovery-role"
  assume_role_policy = data.aws_iam_policy_document.boundary_discovery_trust.json
}

# Permissions: what the plugin needs for discovery
data "aws_iam_policy_document" "boundary_discovery_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeTags",
      "ec2:DescribeImages",
      "ec2:DescribeNetworkInterfaces"
    ]
    resources = ["*"]
  }
}

#Added 2/4/2026
data "aws_iam_policy_document" "boundary_worker_ec2_read" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeTags",
      "ec2:DescribeImages",
      "ec2:DescribeNetworkInterfaces"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "boundary_worker_ec2_read" {
  name   = "boundary-worker-ec2-read"
  role   = aws_iam_role.boundary_worker_role.id
  policy = data.aws_iam_policy_document.boundary_worker_ec2_read.json
}
#End add on 2/4/2026



resource "aws_iam_role_policy" "boundary_discovery_policy" {
  name   = "boundary-aws-discovery-readonly"
  role   = aws_iam_role.boundary_discovery_role.id
  policy = data.aws_iam_policy_document.boundary_discovery_permissions.json
}

# Allow worker to assume discovery role
data "aws_iam_policy_document" "worker_assume_discovery" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.boundary_discovery_role.arn]
  }
}

resource "aws_iam_role_policy" "worker_assume_discovery_policy" {
  name   = "boundary-worker-assume-discovery"
  role   = aws_iam_role.boundary_worker_role.id
  policy = data.aws_iam_policy_document.worker_assume_discovery.json
}


#add S3 bucket perm. 
data "aws_iam_policy_document" "boundary_worker_s3_recording" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.boundary_session_recording_bucket.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.boundary_session_recording_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "boundary_worker_s3_recording" {
  name   = "boundary-worker-s3-recording"
  role   = aws_iam_role.boundary_worker_role.id
  policy = data.aws_iam_policy_document.boundary_worker_s3_recording.json
}
